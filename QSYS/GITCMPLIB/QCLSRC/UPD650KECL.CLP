/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UPD650KECL  CONVERT FILE STRUCTURES TO 6.50 REPACK UPDATE        */
/*  01 August 2013                                                   */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  This CL should be ran to update a given files object library     */
/*  Please prompt and provide two parms.  The first should be the    */
/*  files object library and the second should be the source library */
/*  that those objects will be found.  On DEV2 that could be         */
/*  PIR900FKE for object library and PIRENH650 for source library.   */
/*  On a cusomter box in production that would be PIRF for object    */
/*  library and PIRMODS for source library.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    08/01/13  KDE  6.50                                            */
/*      - Created.                                                   */
/*                                                                   */

             PGM        PARM(&LIBRFROM &SRCLIBR)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&LIBRFROM) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SRCLIBR) TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILECHK) TYPE(*CHAR) LEN(11)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*----  PUT DESIRED LIBRARY AT TOP OF LIST FOR COMPILES         -----*/
             RMVLIBLE   LIB(&LIBRFROM)
             MONMSG     MSGID(CPF0000)
             ADDLIBLE   LIB(&LIBRFROM)
             MONMSG     MSGID(CPF0000)

             CHKOBJ     OBJ(QSYS/&LIBRFROM) OBJTYPE(*LIB)

             CHGVAR     VAR(&FILECHK) VALUE('KITCOMPOLD')
             CHKOBJ     OBJ(&LIBRFROM/&FILECHK) OBJTYPE(*FILE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO CMDLBL(CHKF))
             GOTO       ERROR
CHKF:        CHGVAR     VAR(&FILECHK) VALUE('ITEMFLDOLD')
             CHKOBJ     OBJ(&LIBRFROM/&FILECHK) OBJTYPE(*FILE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO CMDLBL(CHKL))
             GOTO       ERROR
CHKL:        CHGVAR     VAR(&FILECHK) VALUE('ITEMLNKOLD')
             CHKOBJ     OBJ(&LIBRFROM/&FILECHK) OBJTYPE(*FILE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO CMDLBL(CPYK))
             GOTO       ERROR

CPYK:        CPYF       FROMFILE(&LIBRFROM/KITCOMP) +
                          TOFILE(&LIBRFROM/KITCOMPOLD) CRTFILE(*YES)
             CPYF       FROMFILE(&LIBRFROM/ITEMFLD) +
                          TOFILE(&LIBRFROM/ITEMFLDOLD) CRTFILE(*YES)
             CPYF       FROMFILE(&LIBRFROM/ITEMLNK) +
                          TOFILE(&LIBRFROM/ITEMLNKOLD) CRTFILE(*YES)

             DLTF       FILE(&LIBRFROM/KITCOMP1)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(DLTL))
DLTL:        DLTF       FILE(&LIBRFROM/ITEMLNK1)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(DLTK))
DLTK:        DLTF       FILE(&LIBRFROM/KITCOMP)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(DLTPL))
DLTPL:       DLTF       FILE(&LIBRFROM/ITEMLNK)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(DLTT))
DLTT:        DLTF       FILE(&LIBRFROM/PIRTRAN12)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(DLTKI))
DLTKI:       DLTF       FILE(&LIBRFROM/KITITEM)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(CRTK))

CRTK:        CRTPF      FILE(&LIBRFROM/KITCOMP) +
                          SRCFILE(&SRCLIBR/QDDSFILES) SRCMBR(KITCOMP)
             CRTPF      FILE(&LIBRFROM/KITITEM) +
                          SRCFILE(&SRCLIBR/QDDSFILES) SRCMBR(KITITEM)
             CRTPF      FILE(&LIBRFROM/ITEMLNK) +
                          SRCFILE(&SRCLIBR/QDDSFILES) SRCMBR(ITEMLNK)
             CRTLF      FILE(&LIBRFROM/KITCOMP1) +
                          SRCFILE(PIR/QDDSFILES) SRCMBR(KITCOMP1)
             CRTLF      FILE(&LIBRFROM/ITEMLNK1) +
                          SRCFILE(PIR/QDDSFILES) SRCMBR(ITEMLNK1)
             CRTLF      FILE(&LIBRFROM/PIRTRAN12) +
                          SRCFILE(&SRCLIBR/QDDSFILES) +
                          SRCMBR(PIRTRAN12)

             CPYF       FROMFILE(&LIBRFROM/KITCOMPOLD) +
                          TOFILE(&LIBRFROM/KITCOMP) MBROPT(*ADD) +
                          FMTOPT(*MAP)
             CPYF       FROMFILE(&LIBRFROM/ITEMLNKOLD) +
                          TOFILE(&LIBRFROM/ITEMLNK) MBROPT(*ADD) +
                          FMTOPT(*MAP)

             CALL       PGM(UPD650KEA)

/*  Clean up before leaving */
 ERROR:      RCLRSC     LVL(*CALLER)

             ENDPGM
