#include <stdio.h>

int main(int argc, unsigned char *argv[])
{
    unsigned char *buf, *from, *to, *text, *subst;
    FILE *fromfid, *tofid;
    if (argc != 5) {
        fprintf(stderr,"Usage: %s from to text replacement\n",argv[0]);
        exit(1);
    }
    from = argv[1];
    to = argv[2];
    text = argv[3];
    subst = argv[4];
    if (strlen(text) != strlen(subst)) {
        fprintf(stderr,"%s: text and substitution different lengths\n",argv[0]);
        exit(1);
    }
    fromfid = fopen(from,"rb");
    if (fromfid == NULL) {
        perror(from);
        exit(1);
    }
    tofid = fopen(to,"wb");
    if (tofid == NULL) {
        fclose(fromfid);
        perror(to);
        exit(1);
    }
    buf = malloc(strlen(text));
    if (buf == NULL) {
        fprintf(stderr,"%s: memory allocation failure", argv[0]);
        fclose(fromfid);
        fclose(tofid);
        exit(1);
    }
    int pos=0;
    while (1) {
        int c=fgetc(fromfid);
        if (c < 0) {
            if (ferror(fromfid)) perror(from);
            if (pos) {
                if (fwrite(buf,1,pos,tofid) != pos) goto write_error;
            }
            fclose(fromfid);
            fclose(tofid);
            if (ferror(fromfid)) {
                exit(1);
            } else {
                exit(0);
            }
        }
        buf[pos++] = (unsigned char)c;
        if (buf[pos-1] != text[pos-1]) {
            /* text does not match buffer */
            int i;
        shift:
            /* output first character of buf and shift left by 1 */
            if (fputc(buf[0],tofid) < 0) goto write_error;
            for (i=1; i < pos; i++) buf[i-1]=buf[i];
            pos--;
            /* repeat until shifted buf matches start of text */
            for (i=0; i < pos; i++) if (buf[i]!=text[i]) break;
            if (i<pos) goto shift;
        } else if (text[pos]=='\0') {
            /* text matches buffer, so write subst */
            if (fwrite(subst,1,pos,tofid) != pos) goto write_error;
            pos = 0;
        } /* else text matches so far, check next character */
    }

write_error:
    perror(to);
    fclose(from);
    fclose(to);
    exit(1);    
}