/* Copyright (C) 2007 Michael Goffioul
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
*/

#include <octave/oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/file-stat.h>
#include <octave/file-ops.h>
#include <octave/cmd-edit.h>
#include <jni.h>
#ifdef __WIN32__
#include <windows.h>
#endif
#include <octave/load-path.h>
#include <octave/oct-env.h>
#include <octave/oct-shlib.h>

#include <algorithm>
#include <map>

typedef jint (JNICALL *JNI_CreateJavaVM_t) (JavaVM **pvm, JNIEnv **penv, void *args);

extern "C" JNIEXPORT jboolean JNICALL Java_org_octave_Octave_call
  (JNIEnv *, jclass, jstring, jobjectArray, jobjectArray);
  /*
extern "C" JNIEXPORT void JNICALL Java_org_octave_OctListener_doInvokeListener
  (JNIEnv *, jclass, jint, jstring, jobject);
  */
extern "C" JNIEXPORT void JNICALL Java_org_octave_OctaveReference_doFinalize
  (JNIEnv *, jclass, jint);
extern "C" JNIEXPORT void JNICALL Java_org_octave_Octave_doInvoke
  (JNIEnv *, jclass, jint, jobjectArray);
extern "C" JNIEXPORT void JNICALL Java_org_octave_Octave_doEvalString
  (JNIEnv *, jclass, jstring);
extern "C" JNIEXPORT jboolean JNICALL Java_org_octave_Octave_needThreadedInvokation
  (JNIEnv *, jclass);

static JavaVM *jvm = 0;
static JNIEnv *current_env = 0;
static void* jvmLib = 0;

static std::map<int,octave_value> listener_map;
static std::map<int,octave_value> octave_ref_map;
static int octave_refcount = 0;
static long octave_thread_ID = -1;

static bool Vjava_convert_matrix = false;
static bool Vjava_unsigned_conversion = true;

template <class T>
class java_local_ref
{
public:
  java_local_ref (JNIEnv *_env)
    : jobj (0), detached (false), env (_env)
    { }

  java_local_ref (JNIEnv *_env, T obj)
    : jobj (obj), detached (false), env (_env)
    { }

  ~java_local_ref (void)
    {
      release ();
    }

  T& operator= (T obj)
    {
      release ();
      jobj = obj;
      detached = false;
      return jobj;
    }
  operator bool () const { return (jobj != 0); }
  operator T () { return jobj; }

  void detach () { detached = true; }

private:
  void release (void)
    {
      if (env && jobj && ! detached)
        env->DeleteLocalRef (jobj);
      jobj = 0;
    }

  java_local_ref (void)
    : jobj (0), detached (false), env (0)
    { }
	

protected:
  T jobj;
  bool detached;
  JNIEnv *env;
};

typedef java_local_ref<jobject> jobject_ref;
typedef java_local_ref<jclass> jclass_ref;
typedef java_local_ref<jstring> jstring_ref;
typedef java_local_ref<jobjectArray> jobjectArray_ref;
typedef java_local_ref<jintArray> jintArray_ref;
typedef java_local_ref<jbyteArray> jbyteArray_ref;
typedef java_local_ref<jdoubleArray> jdoubleArray_ref;

static octave_value box (JNIEnv* jni_env, jobject jobj, jclass jcls = 0);
static int unbox (JNIEnv* jni_env, const octave_value& val, jobject_ref& jobj, jclass_ref& jcls);
static int unbox (JNIEnv* jni_env, const octave_value_list& args, jobjectArray_ref& jobjs, jobjectArray_ref& jclss);
static dim_vector compute_array_dimensions (JNIEnv* jni_env, jobject obj);

#ifdef __WIN32__
static std::string read_registry_string (const std::string& key, const std::string& value)
{
  HKEY hkey;
  DWORD len;
  std::string retval = "";

  if (! RegOpenKeyEx (HKEY_LOCAL_MACHINE, key.c_str (), 0, KEY_READ, &hkey))
    {
      if (! RegQueryValueEx (hkey, value.c_str (), 0, 0, 0, &len))
        {
          retval.resize (len);
          if (RegQueryValueEx (hkey, value.c_str (), 0, 0, (LPBYTE)&retval[0], &len))
            retval = "";
        }
      RegCloseKey (hkey);
    }
  return retval;
}
#endif

static std::string get_module_path(const std::string& name, bool strip_name = true)
{
  std::string retval;

  retval = octave_env::make_absolute (load_path::find_file (name), 
				      octave_env::getcwd ());

  if (! retval.empty () && strip_name)
    {
      size_t pos = retval.rfind (file_ops::dir_sep_str + name);

      if (pos != NPOS)
        retval.resize (pos);
      else
        retval.resize (0);
    }

  return retval;
}

static std::string initial_java_dir (bool arch_dependent = false)
{
  static std::string path1;
  static std::string path2;

  if (path1.empty())
    {
      path1 = path2 = get_module_path ("__java__.oct", true);

      size_t pos = path2.rfind (file_ops::dir_sep_str);

      if (pos != NPOS)
        path2.resize (pos);
    }

  return (arch_dependent ? path1 : path2);
}

static std::string initial_class_path (void)
{
  std::string retval = initial_java_dir ();

  // check for octave.jar file
  if (! retval.empty ())
    {
      std::string jar_file = retval + file_ops::dir_sep_str + "octave.jar";
      file_stat st (jar_file);

      if (st)
        retval = jar_file;
      else
        retval.resize(0);
    }

  return retval;
}

static octave_shlib jvm_lib;

static bool initialize_jvm (std::string& msg)
{
  if (! jvm)
    {
      JavaVMInitArgs vm_args;
      JavaVMOption options[3];
      std::string init_class_path = initial_class_path ();
      std::string init_octave_path = initial_java_dir (true);
      
      if (init_octave_path.empty())
        {
          msg = "failed to find path of __java__.oct";
          return false;
        }
      if (init_class_path.empty())
        {
          msg = "failed to find path of octave.jar";
          return false;
        }

      init_class_path = "-Djava.class.path=" + init_class_path;
      init_octave_path = "-Doctave.java.path=" + init_octave_path;

      OCTAVE_LOCAL_BUFFER (char, class_path_optionString, 
			   init_class_path.length () + 1);
      strcpy (class_path_optionString, init_class_path.c_str ());
      OCTAVE_LOCAL_BUFFER (char, octave_path_optionString, 
			   init_octave_path.length () + 1);
      strcpy (octave_path_optionString, init_octave_path.c_str ());

      vm_args.version = JNI_VERSION_1_2;
      vm_args.nOptions = 3 /* 3 */;
      options[0].optionString = class_path_optionString;
      options[1].optionString = octave_path_optionString;
      //options[2].optionString = "-Dsun.java2d.opengl=True";
      options[2].optionString = "-Xrs";
      vm_args.options = options;
      vm_args.ignoreUnrecognized = false;

      std::string jvm_lib_path;

#if defined (__WIN32__)
      std::string regval = read_registry_string ("software\\javasoft\\java runtime environment", "Currentversion");
      if (! regval.empty ())
        {
          regval = read_registry_string ("software\\javasoft\\java runtime environment\\" + regval, "RuntimeLib");
          if (! regval.empty())
            jvm_lib_path = regval;
          else
            msg = "unable to find Java Runtime Environment";
        }
      else
        msg = "unable to find Java Runtime Environment";

      if (! jvm_lib_path.empty ())
        {
          octave_shlib lib (jvm_lib_path);

          if (lib)
            {
              JNI_CreateJavaVM_t create_vm = (JNI_CreateJavaVM_t)lib.search("JNI_CreateJavaVM");

              if (create_vm)
                {
                  if (create_vm (&jvm, &current_env, &vm_args) == JNI_OK)
                    {
                      jvm_lib = lib;
                      return true;
                    }
                  else
                    msg = "unable to start Java VM";
                }
              else
                msg = "unable to find correct entry point in JVM library";
            }
          else
            msg = "unable to load Java Runtime Environment";
        }
#else
      if (JNI_CreateJavaVM (&jvm, reinterpret_cast<void **>(&current_env), 
            &vm_args) == JNI_OK)
        return true;
      else
        msg = "unable to start Java VM";
#endif
      return false;
    }

  return true;
}

static void terminate_jvm(void)
{
  if (jvm)
    {
      jvm->DestroyJavaVM ();
      jvm = 0;
      current_env = 0;

      if (jvm_lib)
        jvm_lib.close ();
    }
}

static std::string jstring_to_string (JNIEnv* jni_env, jstring s)
{
  std::string retval;
  if (jni_env)
    {
      const char *cstr = jni_env->GetStringUTFChars (s, 0);
      retval = cstr;
      jni_env->ReleaseStringUTFChars (s, cstr);
    }
  return retval;
}

static std::string jstring_to_string (JNIEnv* jni_env, jobject obj)
{
  std::string retval;
  if (jni_env && obj)
    {
      jclass_ref cls (jni_env, jni_env->FindClass ("java/lang/String"));
      if (cls)
        {
          if (jni_env->IsInstanceOf (obj, cls))
            retval = jstring_to_string (jni_env, reinterpret_cast<jstring> (obj));
        }
    }
  return retval;
}

static octave_value check_exception (JNIEnv* jni_env)
{
  octave_value retval;
  if (jni_env->ExceptionCheck ())
    {
      error ("java exception occured");
      jni_env->ExceptionDescribe ();
      jni_env->ExceptionClear ();
    }
  else
    retval = Matrix ();
  return retval;
}

class octave_java : public octave_base_value
{
public:
  octave_java (void)
    : java_object (0), java_class (0)
    { }

  octave_java (const octave_java& jobj)
    : java_object (0), java_class (0)
    {
      init (jobj.java_object, jobj.java_class);
    }

  octave_java (jobject obj, jclass cls = 0)
    : java_object (0)
    {
      init (obj, cls);
    }

  ~octave_java (void)
    {
      release ();
    }

  jobject to_java () const { return java_object; }
  jclass to_class () const { return java_class; }
  std::string java_class_name () const { return java_type; }
	
  octave_base_value* clone(void) const { return new octave_java(*this); }
  octave_base_value* empty_clone(void) const { return new octave_java(); }

  bool is_defined(void) const { return true; }

  bool is_map (void) const { return true; }

  string_vector map_keys(void) const;

  dim_vector dims(void) const
    {
      if (current_env && java_object)
        return compute_array_dimensions (current_env, java_object);
      else
        return dim_vector (1, 1);
    }

  void print(std::ostream& os, bool pr_as_read_syntax = false) const
    {
      os << "<Java object: " << java_type << ">";
      newline(os);
    }

  void print_raw(std::ostream& os, bool pr_as_read_syntax = false) const
    {
      print(os, pr_as_read_syntax);
    }

  octave_value_list subsref (const std::string& type, const std::list<octave_value_list>& idx, int nargout);
	
  octave_value subsasgn (const std::string& type, const std::list<octave_value_list>& idx, const octave_value& rhs);

  octave_value convert_to_str_internal (bool pad, bool force, char type) const;

  bool is_string (void) const
    {
      if (current_env && java_object)
        {
          jclass_ref cls (current_env, current_env->FindClass ("java/lang/String"));
          return current_env->IsInstanceOf (java_object, cls);
        }
      return false;
    }

private:
  void init (jobject jobj, jclass jcls)
    {
      if (current_env)
        {
          if (jobj)
            java_object = current_env->NewGlobalRef (jobj);
          if (jcls)
            java_class = reinterpret_cast<jclass> (current_env->NewGlobalRef (jcls));
          else if (java_object)
            {
              jclass_ref ocls (current_env, current_env->GetObjectClass (java_object));
              java_class = reinterpret_cast<jclass> (current_env->NewGlobalRef (jclass (ocls)));
            }

          if (java_class)
            {
              jclass_ref clsCls (current_env, current_env->GetObjectClass (java_class));
              jmethodID mID = current_env->GetMethodID (clsCls, "getCanonicalName", "()Ljava/lang/String;");
              jobject_ref resObj (current_env, current_env->CallObjectMethod (java_class, mID));
              java_type = jstring_to_string (current_env, resObj);
            }
        }
    }

  void release ()
    {
      if (current_env)
        {
          if (java_object)
            current_env->DeleteGlobalRef (java_object);
          if (java_class)
            current_env->DeleteGlobalRef (java_class);
          java_object = 0;
          java_class = 0;
        }
    }

private:
  DECLARE_OCTAVE_ALLOCATOR
	
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA

  jobject java_object;
  jclass java_class;
  std::string java_type;
};

DEFINE_OCTAVE_ALLOCATOR (octave_java);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_java,
		"octave_java",
		"octave_java");

static dim_vector compute_array_dimensions (JNIEnv* jni_env, jobject obj)
{
  jobjectArray_ref jobj (jni_env, reinterpret_cast<jobjectArray> (obj));
  jclass_ref jcls (jni_env, jni_env->GetObjectClass (obj));
  jclass_ref ccls (jni_env, jni_env->GetObjectClass (jcls));
  jmethodID isArray_ID = jni_env->GetMethodID (ccls, "isArray", "()Z"),
            getComponentType_ID = jni_env->GetMethodID (ccls, "getComponentType", "()Ljava/lang/Class;");
  dim_vector dv (1, 1);
  int idx = 0;

  jobj.detach ();
  while (jcls && jni_env->CallBooleanMethod (jcls, isArray_ID))
    {
      int len = (jobj ? jni_env->GetArrayLength (jobj) : 0);
      if (idx >= dv.length ())
        dv.resize (idx+1);
      dv (idx) = len;
      jcls = reinterpret_cast<jclass> (jni_env->CallObjectMethod (jcls, getComponentType_ID));
      jobj = (len > 0 ? reinterpret_cast<jobjectArray> (jni_env->GetObjectArrayElement (jobj, 0)) : 0);
      idx++;
    }
  return dv;
}

static jobject make_java_index (JNIEnv* jni_env, const octave_value_list& idx)
{
  jclass_ref ocls (jni_env, jni_env->FindClass ("[I"));
  jobjectArray retval = jni_env->NewObjectArray (idx.length (), ocls, 0);
  for (int i=0; i<idx.length (); i++)
    {
      idx_vector v = idx(i).index_vector ();
      if (! error_state)
        {
          jintArray_ref i_array (jni_env, jni_env->NewIntArray (v.capacity ()));
          jint *buf = jni_env->GetIntArrayElements (i_array, 0);
          for (int k=0; k<v.capacity (); k++)
            buf[k] = v(k);
          jni_env->ReleaseIntArrayElements (i_array, buf, 0);
          jni_env->SetObjectArrayElement (retval, i, i_array);
          check_exception (jni_env);
          if (error_state)
            break;
        }
      else
        break;
    }
  return retval;
}

static octave_value get_array_elements (JNIEnv* jni_env, jobject jobj, const octave_value_list& idx)
{
  octave_value retval;
  jobject_ref resObj (jni_env);
  jobject_ref java_idx (jni_env, make_java_index (jni_env, idx));
  
  if (! error_state)
    {
      jclass_ref helperClass (jni_env, jni_env->FindClass ("org/octave/ClassHelper"));
      jmethodID mID = jni_env->GetStaticMethodID (helperClass, "arraySubsref", "(Ljava/lang/Object;[[I)Ljava/lang/Object;");
      resObj = jni_env->CallStaticObjectMethod (helperClass, mID, jobj, jobject (java_idx));
    }

  if (resObj)
    retval = box (jni_env, resObj);
  else
    retval = check_exception (jni_env);

  return retval;
}

octave_value_list octave_java::subsref(const std::string& type, const std::list<octave_value_list>& idx, int nargout)
{
  octave_value_list retval;
  int skip = 1;

  switch (type[0])
    {
      case '.':
        if (type.length () > 1 && type[1] == '(')
          {
            octave_value_list ovl;
            count++;
            ovl(0) = octave_value (this);
            ovl(1) = (idx.front ())(0);
            std::list<octave_value_list>::const_iterator it = idx.begin ();
            ovl.append (*++it);
            retval = feval (std::string ("java_invoke"), ovl, 1);
            skip++;
          }
        else
          {
            octave_value_list ovl;
            count++;
            ovl(0) = octave_value (this);
            ovl(1) = (idx.front ())(0);
            retval = feval (std::string ("java_get"), ovl, 1);
          }
        break;
      case '(':
        if (current_env)
          retval = get_array_elements (current_env, to_java (), idx.front ());
        break;
      default:
        error ("subsref: Java object cannot be indexed with %c", type[0]);
        break;
    }

  if (idx.size () > 1 && type.length () > 1)
    retval = retval(0).next_subsref (nargout, type, idx, skip);

  return retval;
}

static octave_value set_array_elements (JNIEnv* jni_env, jobject jobj, const octave_value_list& idx, const octave_value& rhs)
{
  octave_value retval;
  jclass_ref rhsCls (jni_env);
  jobject_ref resObj (jni_env), rhsObj (jni_env);
  jobject_ref java_idx (jni_env, make_java_index (jni_env, idx));
  
  if (! error_state && unbox (jni_env, rhs, rhsObj, rhsCls))
    {
      jclass_ref helperClass (jni_env, jni_env->FindClass ("org/octave/ClassHelper"));
      jmethodID mID = jni_env->GetStaticMethodID (helperClass, "arraySubsasgn",
          "(Ljava/lang/Object;[[ILjava/lang/Object;)Ljava/lang/Object;");
      resObj = jni_env->CallStaticObjectMethod (helperClass, mID,
          jobj, jobject (java_idx), jobject (rhsObj));
    }

  if (resObj)
    retval = box (jni_env, resObj);
  else
    retval = check_exception (jni_env);

  return retval;
}

octave_value octave_java::subsasgn (const std::string& type, const std::list<octave_value_list>&idx, const octave_value &rhs)
{
  octave_value retval;

  switch (type[0])
    {
      case '.':
        if (type.length () == 1)
          {
            // field assignment
            octave_value_list ovl;
            count++;
            ovl(0) = octave_value (this);
            ovl(1) = (idx.front ())(0);
            ovl(2) = rhs;
            feval ("java_set", ovl, 0);
            if (! error_state)
              {
                count++;
                retval = octave_value (this);
              }
          }
        else if (type.length () > 2 && type[1] == '(')
          {
            std::list<octave_value_list> new_idx;
            std::list<octave_value_list>::const_iterator it = idx.begin ();
            new_idx.push_back (*it++);
            new_idx.push_back (*it++);
            octave_value_list u = subsref (type.substr (0, 2), new_idx, 1);
            if (! error_state)
              {
                std::list<octave_value_list> next_idx (idx);
                next_idx.erase (next_idx.begin ());
                next_idx.erase (next_idx.begin ());
                u(0).subsasgn (type.substr (2), next_idx, rhs);
                if (! error_state)
                  {
                    count++;
                    retval = octave_value (this);
                  }
              }
	  }
        else if (type[1] == '.')
          {
            octave_value_list u = subsref (type.substr (0, 1), idx, 1);
            if (! error_state)
              {
                std::list<octave_value_list> next_idx (idx);
                next_idx.erase (next_idx.begin ());
                u(0).subsasgn (type.substr (1), next_idx, rhs);
                if (! error_state)
                  {
                    count++;
                    retval = octave_value (this);
                  }
              }
          }
        else
          error ("invalid indexing/assignment on Java object");
        break;
      case '(':
        if (current_env)
          {
            set_array_elements (current_env, to_java (), idx.front (), rhs);
            if (! error_state)
              {
                count++;
                retval = octave_value (this);
              }
          }
        break;
      default:
        error ("Java object cannot be indexed with %c", type[0]);
        break;
    }

  return retval;
}

static string_vector get_invoke_list (JNIEnv* jni_env, jobject jobj)
{
  std::list<std::string> name_list;
  if (jni_env)
  {
    jclass_ref cls (jni_env, jni_env->GetObjectClass (jobj));
    jclass_ref ccls (jni_env, jni_env->GetObjectClass (cls));
    jmethodID getMethods_ID = jni_env->GetMethodID (ccls, "getMethods", "()[Ljava/lang/reflect/Method;"),
              getFields_ID = jni_env->GetMethodID (ccls, "getFields", "()[Ljava/lang/reflect/Field;");
    jobjectArray_ref mList (jni_env, reinterpret_cast<jobjectArray> (jni_env->CallObjectMethod (cls, getMethods_ID))),
                     fList (jni_env, reinterpret_cast<jobjectArray> (jni_env->CallObjectMethod (cls, getFields_ID)));
    int mLen = jni_env->GetArrayLength (mList), fLen = jni_env->GetArrayLength (fList);
    jclass_ref mCls (jni_env, jni_env->FindClass ("java/lang/reflect/Method")),
               fCls (jni_env, jni_env->FindClass ("java/lang/reflect/Field"));
    jmethodID m_getName_ID = jni_env->GetMethodID (mCls, "getName", "()Ljava/lang/String;"),
              f_getName_ID = jni_env->GetMethodID (fCls, "getName", "()Ljava/lang/String;");
    for (int i=0; i<mLen; i++)
      {
        jobject_ref meth (jni_env, jni_env->GetObjectArrayElement (mList, i));
        jstring_ref methName (jni_env, reinterpret_cast<jstring> (jni_env->CallObjectMethod (meth, m_getName_ID)));
        name_list.push_back (jstring_to_string (jni_env, methName));
      }
    for (int i=0; i<fLen; i++)
      {
        jobject_ref field (jni_env, jni_env->GetObjectArrayElement (fList, i));
        jstring_ref fieldName (jni_env, reinterpret_cast<jstring> (jni_env->CallObjectMethod (field, f_getName_ID)));
        name_list.push_back (jstring_to_string (jni_env, fieldName));
      }
  }

  string_vector v (name_list);
  return v.qsort (true);
}

string_vector octave_java::map_keys (void) const
{
  if (current_env)
    return get_invoke_list (current_env, to_java ());
  else
    return string_vector ();
}

static octave_value convert_to_string (JNIEnv *jni_env, jobject java_object, bool force, char type)
{
  octave_value retval;

  if (jni_env && java_object)
    {
      jclass_ref cls (jni_env, jni_env->FindClass ("java/lang/String"));
      if (jni_env->IsInstanceOf (java_object, cls))
        retval = octave_value (jstring_to_string (jni_env, java_object), type);
      else if (force)
        {
          cls = jni_env->FindClass ("[Ljava/lang/String;");
          if (jni_env->IsInstanceOf (java_object, cls))
            {
              jobjectArray array = reinterpret_cast<jobjectArray> (java_object);
              int len = jni_env->GetArrayLength (array);
              Cell c (len, 1);
              for (int i=0; i<len; i++)
                {
                  jstring_ref js (jni_env, reinterpret_cast<jstring> (jni_env->GetObjectArrayElement (array, i)));
                  if (js)
                    c(i) = octave_value (jstring_to_string (jni_env, js), type);
                  else
                    {
                      c(i) = check_exception (jni_env);
                      if (error_state)
                        break;
                    }
                }
              retval = octave_value (c);
            }
          else
            {
              cls = jni_env->FindClass ("java/lang/Object");
              jmethodID mID = jni_env->GetMethodID (cls, "toString", "()Ljava/lang/String;");
              jstring_ref js (jni_env, reinterpret_cast<jstring> (jni_env->CallObjectMethod (java_object, mID)));
              if (js)
                retval = octave_value (jstring_to_string (jni_env, js), type);
              else
                retval = check_exception (jni_env);
            }
        }
      else
        error ("unable to convert Java object to string");
    }

  return retval;
}

octave_value octave_java::convert_to_str_internal (bool, bool force, char type) const
{
  if (current_env)
    return convert_to_string (current_env, to_java (), force, type);
  else
    return octave_value ("");
}

#define TO_JAVA(obj) dynamic_cast<octave_java*>((obj).internal_rep())

static octave_value box (JNIEnv* jni_env, jobject jobj, jclass jcls)
{
  octave_value retval;
  jclass_ref cls (jni_env);

  if (! jobj)
    retval = Matrix ();

  if (retval.is_undefined ())
    {
      cls = jni_env->FindClass ("java/lang/Integer");
      if (jni_env->IsInstanceOf (jobj, cls))
        {
          jmethodID m = jni_env->GetMethodID (cls, "intValue", "()I");
          retval = jni_env->CallIntMethod (jobj, m);
        }
    }

  if (retval.is_undefined ())
    {
      cls = jni_env->FindClass ("java/lang/Double");
      if (jni_env->IsInstanceOf (jobj, cls))
        {
          jmethodID m = jni_env->GetMethodID (cls, "doubleValue", "()D");
          retval = jni_env->CallDoubleMethod (jobj, m);
        }
    }

  if (retval.is_undefined ())
    {
      cls = jni_env->FindClass ("java/lang/Boolean");
      if (jni_env->IsInstanceOf (jobj, cls))
        {
          jmethodID m = jni_env->GetMethodID (cls, "booleanValue", "()Z");
          retval = jni_env->CallBooleanMethod (jobj, m);
        }
    }

  if (retval.is_undefined ())
    {
      cls = jni_env->FindClass ("java/lang/String");
      if (jni_env->IsInstanceOf (jobj, cls))
        {
          retval = jstring_to_string (jni_env, jobj);
        }
    }

  if (retval.is_undefined () && Vjava_convert_matrix)
    {
      cls = jni_env->FindClass ("org/octave/Matrix");
      if (jni_env->IsInstanceOf (jobj, cls))
        {
          jmethodID mID = jni_env->GetMethodID (cls, "getDims", "()[I");
          jintArray_ref iv (jni_env, reinterpret_cast<jintArray> (jni_env->CallObjectMethod (jobj, mID)));
          jint *iv_data = jni_env->GetIntArrayElements (jintArray (iv), 0);
          dim_vector dims;
          dims.resize (jni_env->GetArrayLength (jintArray (iv)));
          for (int i=0; i<dims.length (); i++)
            dims(i) = iv_data[i];
          jni_env->ReleaseIntArrayElements (jintArray (iv), iv_data, 0);
          mID = jni_env->GetMethodID (cls, "getClassName", "()Ljava/lang/String;");
          jstring_ref js (jni_env, reinterpret_cast<jstring> (jni_env->CallObjectMethod (jobj, mID)));
          std::string s = jstring_to_string (jni_env, js);
          if (s == "double")
            {
              NDArray m (dims);
              mID = jni_env->GetMethodID (cls, "toDouble", "()[D");
              jdoubleArray_ref dv (jni_env, reinterpret_cast<jdoubleArray> (jni_env->CallObjectMethod (jobj, mID)));
              jni_env->GetDoubleArrayRegion (dv, 0, m.length (), m.fortran_vec ());
              retval = m;
            }
          else if (s == "byte")
            {
              if (Vjava_unsigned_conversion)
                {
                  uint8NDArray m (dims);
                  mID = jni_env->GetMethodID (cls, "toByte", "()[B");
                  jbyteArray_ref dv (jni_env, reinterpret_cast<jbyteArray> (jni_env->CallObjectMethod (jobj, mID)));
                  jni_env->GetByteArrayRegion (dv, 0, m.length (), (jbyte*)m.fortran_vec ());
                  retval = m;
                }
              else
                {
                  int8NDArray m (dims);
                  mID = jni_env->GetMethodID (cls, "toByte", "()[B");
                  jbyteArray_ref dv (jni_env, reinterpret_cast<jbyteArray> (jni_env->CallObjectMethod (jobj, mID)));
                  jni_env->GetByteArrayRegion (dv, 0, m.length (), (jbyte*)m.fortran_vec ());
                  retval = m;
                }
            }
          else if (s == "integer")
            {
              if (Vjava_unsigned_conversion)
                {
                  uint32NDArray m (dims);
                  mID = jni_env->GetMethodID (cls, "toInt", "()[I");
                  jintArray_ref dv (jni_env, reinterpret_cast<jintArray> (jni_env->CallObjectMethod (jobj, mID)));
                  jni_env->GetIntArrayRegion (dv, 0, m.length (), (jint*)m.fortran_vec ());
                  retval = m;
                }
              else
                {
                  int32NDArray m (dims);
                  mID = jni_env->GetMethodID (cls, "toInt", "()[I");
                  jintArray_ref dv (jni_env, reinterpret_cast<jintArray> (jni_env->CallObjectMethod (jobj, mID)));
                  jni_env->GetIntArrayRegion (dv, 0, m.length (), (jint*)m.fortran_vec ());
                  retval = m;
                }
            }
        }
    }

  if (retval.is_undefined ())
    {
      cls = jni_env->FindClass ("org/octave/OctaveReference");
      if (jni_env->IsInstanceOf (jobj, cls))
        {
          jmethodID mID = jni_env->GetMethodID (cls, "getID", "()I");
          int ID = jni_env->CallIntMethod (jobj, mID);
          std::map<int,octave_value>::iterator it = octave_ref_map.find (ID);

          if (it != octave_ref_map.end ())
            retval = it->second;
        }
    }

  if (retval.is_undefined ())
    retval = octave_value (new octave_java (jobj, jcls));

  return retval;
}

static octave_value box_more (JNIEnv* jni_env, jobject jobj, jclass jcls)
{
  octave_value retval = box (jni_env, jobj, jcls);

  if (retval.class_name () == "octave_java")
    {
      retval = octave_value ();

      jclass_ref cls (jni_env);

      if (retval.is_undefined ())
        {
          cls = jni_env->FindClass ("[D");
          if (jni_env->IsInstanceOf (jobj, cls))
            {
              jdoubleArray jarr = reinterpret_cast<jdoubleArray> (jobj);
              int len = jni_env->GetArrayLength (jarr);
              if (len > 0)
                {
                  Matrix m (1, len);
                  jni_env->GetDoubleArrayRegion (jarr, 0, len, m.fortran_vec ());
                  retval = m;
                }
			  else
                retval = Matrix ();
            }
        }
	  
	  if (retval.is_undefined ())
	  {
        cls = jni_env->FindClass ("[[D");
        if (jni_env->IsInstanceOf (jobj, cls))
          {
            jobjectArray jarr = reinterpret_cast<jobjectArray> (jobj);
            int rows = jni_env->GetArrayLength (jarr), cols = 0;
            if (rows > 0)
              {
                Matrix m;
                for (int r = 0; r < rows; r++)
                  {
                    jdoubleArray_ref row (jni_env, reinterpret_cast<jdoubleArray> (jni_env->GetObjectArrayElement (jarr, r)));
                    if (m.length () == 0)
                      {
                        cols = jni_env->GetArrayLength (row);
                        m.resize (cols, rows);
                      }
                    jni_env->GetDoubleArrayRegion (row, 0, cols, m.fortran_vec () + r * cols);
                  }
                retval = m.transpose ();
              }
            else
              retval = Matrix();
          }
	  }
    }

  if (retval.is_undefined ())
    retval = octave_value (new octave_java (jobj, jcls));

  return retval;
}

static int unbox (JNIEnv* jni_env, const octave_value& val, jobject_ref& jobj, jclass_ref& jcls)
{
  int found = 1;

  if (val.class_name () == "octave_java")
    {
      octave_java *ovj = TO_JAVA (val);
      jobj = ovj->to_java ();
      jobj.detach ();
      jcls = jni_env->GetObjectClass (jobj);
    }
  else if (val.is_string ())
    {
      std::string s = val.string_value ();
      jobj = jni_env->NewStringUTF (s.c_str ());
      jcls = jni_env->GetObjectClass (jobj);
    }
  else if (val.is_real_scalar ())
    {
      double dval = val.double_value ();
      jclass_ref dcls (jni_env, jni_env->FindClass ("java/lang/Double"));
      jfieldID fid = jni_env->GetStaticFieldID (dcls, "TYPE", "Ljava/lang/Class;");
      jmethodID mid = jni_env->GetMethodID (dcls, "<init>", "(D)V");
      jcls = reinterpret_cast<jclass> (jni_env->GetStaticObjectField (dcls, fid));
      jobj = jni_env->NewObject (dcls, mid, dval);
    }
  else if (val.is_empty ())
    {
      jobj = 0;
      //jcls = jni_env->FindClass ("java/lang/Object");
      jcls = 0;
    }
  else if (!Vjava_convert_matrix && ((val.is_real_matrix () && (val.rows() == 1 || val.columns() == 1)) || val.is_range ()))
    {
      Matrix m = val.matrix_value ();
      jdoubleArray dv = jni_env->NewDoubleArray (m.length ());
      //for (int i=0; i<m.length (); i++)
        jni_env->SetDoubleArrayRegion (dv, 0, m.length (), m.fortran_vec ());
      jobj = dv;
      jcls = jni_env->GetObjectClass (jobj);
    }
  else if (Vjava_convert_matrix && (val.is_matrix_type () || val.is_range()) && val.is_real_type ())
    {
      jclass_ref mcls (jni_env, jni_env->FindClass ("org/octave/Matrix"));
      dim_vector dims = val.dims ();
      jintArray_ref iv (jni_env, jni_env->NewIntArray (dims.length ()));
      jint *iv_data = jni_env->GetIntArrayElements (jintArray (iv), 0);
      for (int i=0; i<dims.length (); i++)
        iv_data[i] = dims(i);
      jni_env->ReleaseIntArrayElements (jintArray (iv), iv_data, 0);
      if (val.is_double_type ())
        {
          NDArray m = val.array_value ();
          jdoubleArray_ref dv (jni_env, jni_env->NewDoubleArray (m.length ()));
          jni_env->SetDoubleArrayRegion (jdoubleArray (dv), 0, m.length (), m.fortran_vec ());
          jmethodID mID = jni_env->GetMethodID (mcls, "<init>", "([D[I)V");
          jobj = jni_env->NewObject (jclass (mcls), mID, jdoubleArray (dv), jintArray (iv));
          jcls = jni_env->GetObjectClass (jobj);
        }
      else if (val.is_int8_type ())
        {
          int8NDArray m = val.int8_array_value ();
          jbyteArray_ref bv (jni_env, jni_env->NewByteArray (m.length ()));
          jni_env->SetByteArrayRegion (jbyteArray (bv), 0, m.length (), (jbyte*)m.fortran_vec ());
          jmethodID mID = jni_env->GetMethodID (mcls, "<init>", "([B[I)V");
          jobj = jni_env->NewObject (jclass (mcls), mID, jbyteArray (bv), jintArray (iv));
          jcls = jni_env->GetObjectClass (jobj);
        }
      else if (val.is_uint8_type ())
        {
          uint8NDArray m = val.uint8_array_value ();
          jbyteArray_ref bv (jni_env, jni_env->NewByteArray (m.length ()));
          jni_env->SetByteArrayRegion (jbyteArray (bv), 0, m.length (), (jbyte*)m.fortran_vec ());
          jmethodID mID = jni_env->GetMethodID (mcls, "<init>", "([B[I)V");
          jobj = jni_env->NewObject (jclass (mcls), mID, jbyteArray (bv), jintArray (iv));
          jcls = jni_env->GetObjectClass (jobj);
        }
      else if (val.is_int32_type ())
        {
          int32NDArray m = val.int32_array_value ();
          jintArray_ref v (jni_env, jni_env->NewIntArray (m.length ()));
          jni_env->SetIntArrayRegion (jintArray (v), 0, m.length (), (jint*)m.fortran_vec ());
          jmethodID mID = jni_env->GetMethodID (mcls, "<init>", "([I[I)V");
          jobj = jni_env->NewObject (jclass (mcls), mID, jintArray (v), jintArray (iv));
          jcls = jni_env->GetObjectClass (jobj);
        }
      else
        {
          found = 0;
          error ("cannot convert matrix of type `%s'", val.class_name ().c_str ());
        }
    }
  else if (val.is_cellstr ())
    {
      Cell cellStr = val.cell_value ();
      jclass_ref scls (jni_env, jni_env->FindClass ("java/lang/String"));
      jobjectArray array = jni_env->NewObjectArray (cellStr.length (), scls, 0);
      for (int i=0; i<cellStr.length (); i++)
        {
          jstring_ref jstr (jni_env, jni_env->NewStringUTF (cellStr(i).string_value().c_str()));
          jni_env->SetObjectArrayElement (array, i, jstr);
        }
      jobj = array;
      jcls = jni_env->GetObjectClass (jobj);
    }
  else
    {
      jclass rcls = jni_env->FindClass ("org/octave/OctaveReference");
      jmethodID mID = jni_env->GetMethodID (rcls, "<init>", "(I)V");
      int ID = octave_refcount++;

      jobj = jni_env->NewObject (rcls, mID, ID);
      jcls = rcls;
      octave_ref_map[ID] = val;
    }

  return found;
}

static int unbox (JNIEnv* jni_env, const octave_value_list& args, jobjectArray_ref& jobjs, jobjectArray_ref& jclss)
{
  int found = 1;
  jclass_ref ocls (jni_env, jni_env->FindClass ("java/lang/Object"));
  jclass_ref ccls (jni_env, jni_env->FindClass ("java/lang/Class"));

  if (! jobjs)
    jobjs = jni_env->NewObjectArray (args.length (), ocls, 0);
  if (! jclss)
    jclss = jni_env->NewObjectArray (args.length (), ccls, 0);
  for (int i=0; i<args.length (); i++)
    {
      jobject_ref jobj (jni_env);
      jclass_ref jcls (jni_env);

      if (! unbox (jni_env, args(i), jobj, jcls))
        {
          found = 0;
          break;
        }
      jni_env->SetObjectArrayElement (jobjs, i, jobj);
      jni_env->SetObjectArrayElement (jclss, i, jcls);
    }

  return found;
}

static octave_value do_java_invoke (JNIEnv* jni_env, octave_java *obj,
    const std::string& name, const octave_value_list& args)
{
  octave_value retval;

  if (jni_env)
    {
      jobjectArray_ref arg_objs (jni_env), arg_types (jni_env);
      if (unbox (jni_env, args, arg_objs, arg_types))
        {
          jclass_ref helperClass (jni_env, jni_env->FindClass ("org/octave/ClassHelper"));
          jmethodID mID = jni_env->GetStaticMethodID (helperClass, "invokeMethod",
              "(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;[Ljava/lang/Class;)Ljava/lang/Object;");
          jstring_ref methName (jni_env, jni_env->NewStringUTF (name.c_str ()));
          jobjectArray_ref resObj (jni_env, reinterpret_cast<jobjectArray> (jni_env->CallStaticObjectMethod (helperClass, mID,
              obj->to_java (), jstring (methName), jobjectArray (arg_objs), jobjectArray (arg_types))));
          if (resObj)
            retval = box (jni_env, resObj);
          else
            retval = check_exception (jni_env);
        }
    }
  return retval;
}

static octave_value do_java_invoke (JNIEnv* jni_env, const std::string& class_name,
    const std::string& name, const octave_value_list& args)
{
  octave_value retval;

  if (jni_env)
    {
      jobjectArray_ref arg_objs (jni_env), arg_types (jni_env);
      if (unbox (jni_env, args, arg_objs, arg_types))
        {
          jclass_ref helperClass (jni_env, jni_env->FindClass ("org/octave/ClassHelper"));
          jmethodID mID = jni_env->GetStaticMethodID (helperClass, "invokeStaticMethod",
              "(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;[Ljava/lang/Class;)Ljava/lang/Object;");
          jstring_ref methName (jni_env, jni_env->NewStringUTF (name.c_str ()));
          jstring_ref clsName (jni_env, jni_env->NewStringUTF (class_name.c_str ()));
          jobject_ref resObj (jni_env, jni_env->CallStaticObjectMethod (helperClass, mID,
              jstring (clsName), jstring (methName), jobjectArray (arg_objs), jobjectArray (arg_types)));
          if (resObj)
            retval = box (jni_env, resObj);
          else
            retval = check_exception (jni_env);
        }
    }
  return retval;
}


static octave_value do_java_create (JNIEnv* jni_env, const std::string& name, const octave_value_list& args)
{
  octave_value retval;

  if (jni_env)
    {
      jobjectArray_ref arg_objs (jni_env), arg_types (jni_env);
      if (unbox (jni_env, args, arg_objs, arg_types))
        {
          jclass_ref helperClass (jni_env, jni_env->FindClass ("org/octave/ClassHelper"));
          jmethodID mID = jni_env->GetStaticMethodID (helperClass, "invokeConstructor",
              "(Ljava/lang/String;[Ljava/lang/Object;[Ljava/lang/Class;)Ljava/lang/Object;");
          jstring_ref clsName (jni_env, jni_env->NewStringUTF (name.c_str ()));
          jobject_ref resObj (jni_env, jni_env->CallStaticObjectMethod (helperClass, mID,
              jstring (clsName), jobjectArray (arg_objs), jobjectArray (arg_types)));
          if (resObj)
            retval = box (jni_env, resObj);
          else
            check_exception (jni_env);
        }
    }
  return retval;
}

static octave_value do_java_get (JNIEnv* jni_env, octave_java *obj, const std::string& name)
{
  octave_value retval;

  if (jni_env)
    {
      jclass_ref helperClass (jni_env, jni_env->FindClass ("org/octave/ClassHelper"));
      jmethodID mID = jni_env->GetStaticMethodID (helperClass, "getField",
          "(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;");
      jstring_ref fName (jni_env, jni_env->NewStringUTF (name.c_str ()));
      jobject_ref resObj (jni_env, jni_env->CallStaticObjectMethod (helperClass, mID,
          obj->to_java (), jstring (fName)));
      if (resObj)
        retval = box (jni_env, resObj);
      else
        retval = check_exception (jni_env);
    }
  return retval;
}

static octave_value do_java_get (JNIEnv* jni_env, const std::string& class_name, const std::string& name)
{
  octave_value retval;

  if (jni_env)
    {
      jclass_ref helperClass (jni_env, jni_env->FindClass ("org/octave/ClassHelper"));
      jmethodID mID = jni_env->GetStaticMethodID (helperClass, "getStaticField",
          "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;");
      jstring_ref cName (jni_env, jni_env->NewStringUTF (class_name.c_str ()));
      jstring_ref fName (jni_env, jni_env->NewStringUTF (name.c_str ()));
      jobject_ref resObj (jni_env, jni_env->CallStaticObjectMethod (helperClass, mID,
          jstring (cName), jstring (fName)));
      if (resObj)
        retval = box (jni_env, resObj);
      else
        retval = check_exception (jni_env);
    }
  return retval;
}

static octave_value do_java_set (JNIEnv* jni_env, octave_java *obj, const std::string& name, const octave_value& val)
{
  octave_value retval;

  if (jni_env)
    {
      jobject_ref jobj (jni_env);
      jclass_ref jcls (jni_env);

      if (unbox (jni_env, val, jobj, jcls))
        {
          jclass_ref helperClass (jni_env, jni_env->FindClass ("org/octave/ClassHelper"));
          jmethodID mID = jni_env->GetStaticMethodID (helperClass, "setField",
              "(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V");
          jstring_ref fName (jni_env, jni_env->NewStringUTF (name.c_str ()));
          jni_env->CallStaticObjectMethod (helperClass, mID, obj->to_java (), jstring (fName), jobject (jobj));
          check_exception (jni_env);
        }
    }
  return retval;
}

static octave_value do_java_set (JNIEnv* jni_env, const std::string& class_name, const std::string& name, const octave_value& val)
{
  octave_value retval;

  if (jni_env)
    {
      jobject_ref jobj (jni_env);
      jclass_ref jcls (jni_env);

      if (unbox (jni_env, val, jobj, jcls))
        {
          jclass_ref helperClass (jni_env, jni_env->FindClass ("org/octave/ClassHelper"));
          jmethodID mID = jni_env->GetStaticMethodID (helperClass, "setStaticField",
              "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V");
          jstring_ref cName (jni_env, jni_env->NewStringUTF (class_name.c_str ()));
          jstring_ref fName (jni_env, jni_env->NewStringUTF (name.c_str ()));
          jni_env->CallStaticObjectMethod (helperClass, mID, jstring (cName), jstring (fName), jobject (jobj));
          check_exception (jni_env);
        }
    }
  return retval;
}

static long get_current_thread_ID(JNIEnv *jni_env)
{
  if (jni_env)
    {
      jclass_ref cls (jni_env, jni_env->FindClass ("java/lang/Thread"));
      jmethodID mID = jni_env->GetStaticMethodID (cls, "currentThread", "()Ljava/lang/Thread;");
      jobject_ref jthread (jni_env, jni_env->CallStaticObjectMethod (cls, mID));
      if (jthread)
        {
          jclass_ref jth_cls (jni_env, jni_env->GetObjectClass (jthread));
          mID = jni_env->GetMethodID (jth_cls, "getId", "()J");
		  long result = jni_env->CallLongMethod (jthread, mID);
		  //printf("current java thread ID = %ld\n", result);
		  return result;
        }
    }
  return -1;
}

static int java_event_hook (void)
{
  if (current_env)
    {
      jclass_ref cls (current_env, current_env->FindClass ("org/octave/Octave"));
      jmethodID mID = current_env->GetStaticMethodID (cls, "checkPendingAction", "()V");
      current_env->CallStaticVoidMethod (cls, mID);
    }
  return 0;
}

static void initialize_java (void)
{
  if (! jvm)
    {
      std::string msg;
      if (initialize_jvm (msg))
        {
          octave_java::register_type ();
          command_editor::set_event_hook (java_event_hook);
          octave_thread_ID = get_current_thread_ID (current_env);
          //printf("octave thread ID=%ld\n", octave_thread_ID);
        }
      else
        error (msg.c_str ());
    }
}

DEFUN_DLD (java_init, args, , "")
{
  
  octave_value retval;

  retval = 0;
  initialize_java ();
  if (! error_state)
    retval = 1;

  return retval;
}

DEFUN_DLD (java_exit, args, , "")
{
  octave_value retval;

  terminate_jvm ();

  return retval;
}

DEFUN_DLD (java_new, args, ,
    "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{obj} =} java_new (@var{name}, @var{arg1}, ...)\n\
Create a Java object of class @var{name}, by calling the class constructor with the\n\
arguments @var{arg1}, ...\n\
\n\
@example\n\
  x = java_new (\"java.lang.StringBuffer\", \"Initial string\")\n\
@end example\n\
\n\
@seealso{java_invoke, java_get, java_set}\n\
@end deftypefn")
{
  octave_value retval;

  initialize_java ();
  if (! error_state)
    {
      if (args.length () > 0)
        {
          std::string name = args(0).string_value ();
          if (! error_state)
          {
            octave_value_list tmp;
            for (int i=1; i<args.length (); i++)
              tmp(i-1) = args(i);
            retval = do_java_create (current_env, name, tmp);
          }
          else
            error ("java_new: first argument must be a string");
        }
      else
        print_usage ();
    }

  return retval;
}

DEFUN_DLD (java_invoke, args, ,
    "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{ret} =} java_invoke (@var{obj}, @var{name}, @var{arg1}, ...)\n\
Invoke the method @var{name} on the Java object @var{obj} with the arguments\n\
@var{arg1}, ... For static methods, @var{obj} can be a string representing the\n\
fully qualified name of the corresponding class. The function returns the result\n\
of the method invocation.\n\
\n\
When @var{obj} is a regular Java object, the structure-like indexing can be used\n\
as a shortcut syntax. For instance, the two following statements are equivalent\n\
\n\
@example\n\
  ret = java_invoke (x, \"method1\", 1.0, \"a string\")\n\
  ret = x.method1 (1.0, \"a string\")\n\
@end example\n\
\n\
@seealso{java_get, java_set, java_new}\n\
@end deftypefn")
{
  octave_value retval;

  initialize_java ();
  if (! error_state)
    {
      if (args.length() > 1)
        {
          std::string name = args(1).string_value ();
          if (! error_state)
            {
              octave_value_list tmp;
              for (int i=2; i<args.length (); i++)
                tmp(i-2) = args(i);

              if (args(0).class_name () == "octave_java")
                {
                  octave_java *jobj = TO_JAVA (args(0));
                  retval = do_java_invoke (current_env, jobj, name, tmp);
                }
              else if (args(0).is_string ())
                {
                  std::string cls = args(0).string_value ();
                  retval = do_java_invoke (current_env, cls, name, tmp);
                }
              else
                error ("java_invoke: first argument must be a Java object or a string");
            }
          else
            error ("java_invoke: second argument must be a string");
        }
      else
        print_usage ();
    }

  return retval;
}

DEFUN_DLD (java_get, args, ,
    "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{val} =} java_get (@var{obj}, @var{name})\n\
Get the value of the field @var{name} of the Java object @var{obj}. For\n\
static fields, @var{obj} can be a string representing the fully qualified\n\
name of the corresponding class.\n\
\n\
When @var{obj} is a regular Java object, the structure-like indexing can be used\n\
as a shortcut syntax. For instance, the two following statements are equivalent\n\
\n\
@example\n\
  java_get (x, \"field1\")\n\
  x.field1\n\
@end example\n\
\n\
@seealso{java_set, java_invoke, java_new}\n\
@end deftypefn")
{
  octave_value retval;

  initialize_java ();
  if (! error_state)
    {
      if (args.length () == 2)
        {
          std::string name = args(1).string_value ();
          if (! error_state)
            {
              if (args(0).class_name () == "octave_java")
                {
                  octave_java *jobj = TO_JAVA (args(0));
                  retval = do_java_get (current_env, jobj, name);
                }
              else if (args(0).is_string ())
                {
                  std::string cls = args(0).string_value ();
                  retval = do_java_get (current_env, cls, name);
                }
              else
                error ("java_get: first argument must be a Java object or a string");
            }
          else
            error ("java_get: second argument must be a string");
        }
      else
        print_usage ();
    }

  return retval;
}

DEFUN_DLD (java_set, args, ,
    "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{obj} =} java_set (@var{obj}, @var{name}, @var{val})\n\
Set the value of the field @var{name} of the Java object @var{obj} to @var{val}.\n\
For static fields, @var{obj} can be a string representing the fully qualified named\n\
of the corresponding Java class.\n\
\n\
When @var{obj} is a regular Java object, the structure-like indexing can be used as\n\
a shortcut syntax. For instance, the two following statements are equivalent\n\
\n\
@example\n\
  java_set (x, \"field1\", val)\n\
  x.field1 = val\n\
@end example\n\
\n\
@seealso{java_get, java_invoke, java_new}\n\
@end deftypefn")
{
  octave_value retval;

  initialize_java ();
  if (! error_state)
    {
      if (args.length () == 3)
        {
          std::string name = args(1).string_value ();
          if (! error_state)
            {
              if (args(0).class_name () == "octave_java")
                {
                  octave_java *jobj = TO_JAVA (args(0));
                  retval = do_java_set (current_env, jobj, name, args(2));
                }
              else if (args(0).is_string ())
                {
                  std::string cls = args(0).string_value ();
                  retval = do_java_set (current_env, cls, name, args(2));
                }
              else
                error ("java_set: first argument must be a Java object or a string");
            }
          else
            error ("java_set: second argument must be a string");
        }
      else
        print_usage ();
    }

  return retval;
}

DEFUN_DLD (java2mat, args, , "")
{
  octave_value_list retval;

  initialize_java ();
  if (! error_state)
    {
      if (args.length () == 1)
        {
          if (args(0).class_name () == "octave_java")
            {
              octave_java *jobj = TO_JAVA (args(0));
              retval(0) = box_more (current_env, jobj->to_java (), 0);
            }
          else
            retval(0) = args(0);
        }
      else
        print_usage ();
    }

  return retval;
}

DEFUN_DLD (__java__, args, , "")
{
  return octave_value ();
}

DEFUN_DLD (java_convert_matrix, args, nargout, "")
{
  return SET_INTERNAL_VARIABLE (java_convert_matrix);
}

DEFUN_DLD (java_unsigned_conversion, args, nargout, "")
{
  return SET_INTERNAL_VARIABLE (java_unsigned_conversion);
}

JNIEXPORT jboolean JNICALL Java_org_octave_Octave_call
  (JNIEnv *env, jclass, jstring funcName, jobjectArray argin, jobjectArray argout)
{
  std::string fname = jstring_to_string (env, funcName);
  int nargout = env->GetArrayLength (argout);
  int nargin = env->GetArrayLength (argin);
  octave_value_list varargin, varargout;

  for (int i=0; i<nargin; i++)
    varargin(i) = box (env, env->GetObjectArrayElement (argin, i), 0);
  varargout = feval (fname, varargin, nargout);

  if (! error_state)
    {
      jobjectArray_ref out_objs (env, argout), out_clss (env);

      out_objs.detach ();
      if (unbox (env, varargout, out_objs, out_clss))
        return true;
    }

  return false;
}

JNIEXPORT void JNICALL Java_org_octave_OctaveReference_doFinalize
  (JNIEnv *env, jclass, jint ID)
{
  octave_ref_map.erase (ID);
}

JNIEXPORT void JNICALL Java_org_octave_Octave_doInvoke
  (JNIEnv *env, jclass, jint ID, jobjectArray args)
{
  std::map<int,octave_value>::iterator it = octave_ref_map.find (ID);

  if (it != octave_ref_map.end ())
    {
      octave_value val = it->second;
      int len = env->GetArrayLength (args);
      octave_value_list oct_args;

      for (int i=0; i<len; i++)
        {
          jobject_ref jobj (env, env->GetObjectArrayElement (args, i));
          oct_args(i) = box (env, jobj, 0);
          if (error_state)
            break;
        }

      if (! error_state)
        {
          if (val.is_function_handle ())
            {
              octave_function *fcn = val.function_value ();
              feval (fcn, oct_args);
            }
          else if (val.is_cell () && val.length () > 0 &&
              (val.rows () == 1 || val.columns() == 1) &&
              val.cell_value()(0).is_function_handle ())
            {
              Cell c = val.cell_value ();
              octave_function *fcn = c(0).function_value ();

              for (int i=1; i<c.length (); i++)
                oct_args(len+i-1) = c(i);

              if (! error_state)
                feval (fcn, oct_args);
            }
		  else
            error ("trying to invoke non-invocable object");
        }
    }
}

JNIEXPORT void JNICALL Java_org_octave_Octave_doEvalString
  (JNIEnv *env, jclass, jstring cmd)
{
  std::string s = jstring_to_string (env, cmd);
  int pstatus;

  eval_string (s, false, pstatus, 0);
}

JNIEXPORT jboolean JNICALL Java_org_octave_Octave_needThreadedInvokation
  (JNIEnv *env, jclass)
{
  return (get_current_thread_ID (env) != octave_thread_ID);
}
