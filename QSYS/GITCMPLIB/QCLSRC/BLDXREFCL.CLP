/*-------------------------------------------------------------------*/
/*                                                                   */
/*  BLDMRCXREF  CREATE FILES AND RPG TO RUN MRC CROSS REF            */
/*  08 November 2017                                                 */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    11/08/17  KDE  7.10                                            */
/*      - Created.                                                   */
/*-------------------------------------------------------------------*/

BLDMRCXREF:  PGM        PARM(&RPGLIB &GLOLIB)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Library to build RPG program BLDMRCXREF                         (710 A) */

             DCL        VAR(&RPGLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&GLOLIB) TYPE(*CHAR) LEN(10)

             DLTF       FILE(&GLOLIB/MRCOBJXREF)
             MONMSG     MSGID(CPF0000)

             DLTF       FILE(&GLOLIB/MRCTFRRECS)
             MONMSG     MSGID(CPF0000)

             DLTF       FILE(&GLOLIB/TEXTFILE)
             MONMSG     MSGID(CPF0000)

             /* create FILES      */
             CRTPF      FILE(&GLOLIB/MRCOBJXREF) +
                          SRCFILE(MRCOBJXREF/QDDSFILES) SIZE(*NOMAX)

             CRTPF      FILE(&GLOLIB/MRCTFRRECS) +
                          SRCFILE(MRCOBJXREF/QDDSFILES) SIZE(*NOMAX)

             CRTPF      FILE(&GLOLIB/TEXTFILE) +
                          SRCFILE(MRCOBJXREF/QDDSFILES) SIZE(*NOMAX)

             /* create RPG Program     */
             CPYF       FROMFILE(&GLOLIB/TEXTFILE) +
                          TOFILE(QTEMP/TEXTFILE) CRTFILE(*YES)
             MONMSG     MSGID(CPF0000)
             CPYF       FROMFILE(&GLOLIB/MRCTFRRECS) +
                          TOFILE(QTEMP/MRCTFRRECS) CRTFILE(*YES)
             MONMSG     MSGID(CPF0000)
             CRTSQLRPGI OBJ(&RPGLIB/BLDMRCXREF) +
                          SRCFILE(MRCOBJXREF/QRPGSRC) COMMIT(*NONE) +
                          CLOSQLCSR(*ENDMOD) DLYPRP(*YES) +
                          DBGVIEW(*SOURCE)

             ENDPGM
