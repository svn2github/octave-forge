/*
 * Copyright (c) 2008, Xavier Delacour <xavier.delacour@gmail.com>
 *
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the BSD License. For details see the COPYING
 * file included as part of this distribution.
 */

// docs here: http://nbpfaus.net/~pfau/ftplib/

%module ftpobj

%include <std_string.i>

%{
#include <ftplib.h>
#include <algorithm>
#include <sstream>
%}

// * does host:port syntax work?

// * are wildcards handled properly by ftplib (or the remote end?)
// * seems unlikely, given the interface

// * mget: does output==path match matlab behavior?

// * mget: this doesn't do recursive mget when given a directory

// * mget: doesn't return the send or received paths correctly

// * mput: doesn't handle wildcard or recursive directory uploading

%include "docs.i"

// **********************************************************************
// ftp object

%inline {
  class ftp {
    std::string read_entire(const char* path,int type,int mode) {
      netbuf *read_obj;
      if (!FtpAccess(path,type,mode,obj,&read_obj)) {
	error("failed to open %s for reading",path);
	return std::string();
      }
      std::string ret;
      char buf[4096];
      for (;;) {
	int rdlen=FtpRead(buf,sizeof(buf),read_obj);
	if (rdlen<=0)
	  break;
	ret.insert(ret.end(),buf,buf+rdlen);
      }
      if (!FtpClose(read_obj))
	error("failed to close %s",path);
      return ret;
    }
    Cell read_dir(const char* path,int type) {
      std::string s=read_entire(path,type,FTPLIB_ASCII);
      std::stringstream sin(s);
      std::vector<std::string> tmp;
      std::string line;
      while (getline(sin,line))
	tmp.push_back(line);
      Cell c(1,tmp.size());
      for (int j=0;j<tmp.size();++j)
	c(j)=tmp[j];
      return c;
    }

    netbuf *obj;
    std::string host;
    std::string user;
    char mode;
  public:

#define check_connected(ret) \
  if (!obj) { \
    error("not connected"); \
    return ret; \
  }

    ftp(const char* _host,const char* _user="anonymous",const char* pass="")
      : obj(0),host(_host),user(_user),mode(FTPLIB_ASCII) {
      FtpInit();
      if (!FtpConnect(host.c_str(),&obj))
	error("connection to %s failed",host.c_str());
      else if (!FtpLogin(user.c_str(),pass,obj))
	error("login to %s failed",host.c_str());
    }

    ~ftp() {
      close();
    }

    void close() {
      if (obj)
	FtpQuit(obj);
      obj=0;
    }

    int cd(const char* path) {
      check_connected(0);
      if (!strcmp(path,".."))
	return FtpCDUp(obj);
      return FtpChdir(path,obj);
    }

    std::string pwd() {
      check_connected(0);
      char buf[512]={0};
      FtpPwd(&buf[0],sizeof(buf),obj);
      return buf;
    }

    Cell ls(const char* path=".") {
      return nlst(path);
    }

    Cell nlst(const char* path=".") {
      check_connected(Cell());
      return read_dir(path,FTPLIB_DIR);
    }

    Cell dir(const char* path=".") {
      check_connected(Cell());
      return read_dir(path,FTPLIB_DIR_VERBOSE);
    }

    int rmdir(const char* path) {
      check_connected(0);
      return FtpRmdir(path,obj);
    }

    int mkdir(const char* path) {
      check_connected(0);
      return FtpMkdir(path,obj);
    }

    int get(const char* output,const char* path) {
      check_connected(0);
      return FtpGet(output,path,mode,obj);
    }

    int put(const char* input,const char* path) {
      check_connected(0);
      return FtpPut(input,path,mode,obj);
    }

    int rename(const char* src,const char* dst) {
      check_connected(0);
      return FtpRename(src,dst,obj);
    }

    int remove(const char* fn) {
      check_connected(0);
      return FtpDelete(fn,obj);
    }

    void mget(const char* fn) {
      if (!get(fn,fn))
	error("ftp mget failed");
    }

    void mget(const octave_value_list& varargs,...) {
      for (int j=0;j<varargs.length();++j)
	if (!varargs(j).is_string()) {
	  error("filenames and target must be strings");
	  return;
	}

      std::string target=varargs(varargs.length()-1).string_value();
      if (target.size()&&target.end()[-1]=='/')
	target.erase(target.end()-1);

      for (int j=0;j<varargs.length()-1;++j) {
	std::string src=varargs(j).string_value();
	std::string dst=target + "/" + varargs(j).string_value();
	if (!get(src.c_str(),dst.c_str())) {
	  error("ftp get of %s into %s failed",src.c_str(),dst.c_str());
	  return;
	}
      }
    }

    void mput(const char* fn) {
      if (!put(fn,fn))
	error("ftp mput failed");
    }

    void ascii() {
      mode=FTPLIB_ASCII;
    }

    void binary() {
      mode=FTPLIB_BINARY;
    }

    std::string __str() {
      check_connected(0);
      std::stringstream sout;
      sout<<"FTP Object"<<std::endl;
      sout<<" host: "<<host<<std::endl;
      sout<<" user: "<<user<<std::endl;
      sout<<" dir: "<<pwd()<<std::endl;
      sout<<" mode: "<<(mode==FTPLIB_BINARY?"binary":"ascii")<<std::endl;
      return sout.str();
    }
  };

}
