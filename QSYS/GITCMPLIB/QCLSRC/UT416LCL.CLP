/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT416LCL  Change license field in files 416 Update               */
/*  07 February 2003                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &RSTLIB   Program library to be updated                  */
/*        &RSTLIBF  File library to be updated                     */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

 UT416LCL:    PGM       PARM(&RSTLIB &RSTLIBF &RETURN)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&RSTLIB)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&RSTLIBF)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)

   /* Standard message handling variables */

             DCL        VAR(&ABORT)    TYPE(*LGL)  VALUE('0')
             DCL        VAR(&ERRFLAG)  TYPE(*LGL)  VALUE('1')
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Copy N. files to N files */
          CPYF  FROMFILE(&RSTLIBF/N.EXPFPOR) +
                TOFILE(&RSTLIBF/NEXPFPOR) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/N.LICENSE) +
                TOFILE(&RSTLIBF/NLICENSE) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/N.LOG200) +
                TOFILE(&RSTLIBF/NLOG200) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/N.PORCV) +
                TOFILE(&RSTLIBF/NPORCV) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/N.WORKPUT) +
                TOFILE(&RSTLIBF/NWORKPUT) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/N.WRKSTGP) +
                TOFILE(&RSTLIBF/NWRKSTGP) CRTFILE(*YES)
/*        CPYF  FROMFILE(&RSTLIBF/N.ER331) +             */
/*              TOFILE(&RSTLIBF/NER331) CRTFILE(*YES)    */
/*        CPYF  FROMFILE(&RSTLIBF/N.ER341) +             */
/*              TOFILE(&RSTLIBF/NER341) CRTFILE(*YES)    */
/*        CPYF  FROMFILE(&RSTLIBF/N.PT331) +             */
/*              TOFILE(&RSTLIBF/NPT331) CRTFILE(*YES)    */

/*  Delete logical files     */

             CHKOBJ     OBJ(&RSTLIBF/LICENSE1) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                        GOTO SKIPDEL1
                        ENDDO
             DLTF       FILE(&RSTLIBF/LICENSE1)

 SKIPDEL1:   CHKOBJ     OBJ(&RSTLIBF/PORCV1) OBJTYPE(*FILE) MBR(*NONE  )
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL2)
             DLTF       FILE(&RSTLIBF/PORCV1)

 SKIPDEL2:   CHKOBJ     OBJ(&RSTLIBF/PORCV2) OBJTYPE(*FILE) MBR(*NONE  )
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL3)
             DLTF       FILE(&RSTLIBF/PORCV2)

 SKIPDEL3:   CHKOBJ     OBJ(&RSTLIBF/PORCV3) OBJTYPE(*FILE) MBR(*NONE  )
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL4)
             DLTF       FILE(&RSTLIBF/PORCV3)

 SKIPDEL4:   CHKOBJ     OBJ(&RSTLIBF/PODTL3) OBJTYPE(*FILE) MBR(*NONE  )
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL5)
             DLTF       FILE(&RSTLIBF/PODTL3)

 SKIPDEL5:   CHKOBJ     OBJ(&RSTLIBF/WORKPUT1) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL6)
             DLTF       FILE(&RSTLIBF/WORKPUT1)

 SKIPDEL6:   CHKOBJ     OBJ(&RSTLIBF/WORKPUT2) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL7)
             DLTF       FILE(&RSTLIBF/WORKPUT2)

 SKIPDEL7:   CHKOBJ     OBJ(&RSTLIBF/WRKSTGP1) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL8)
             DLTF       FILE(&RSTLIBF/WRKSTGP1)

 SKIPDEL8:   CHKOBJ     OBJ(&RSTLIBF/WRKSTGP2) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL9)
             DLTF       FILE(&RSTLIBF/WRKSTGP2)

 SKIPDEL9:

/*  On with the show ... */

             CHKOBJ     OBJ(&RSTLIBF/NEXPFPOR) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL1)
             CHKOBJ     OBJ(&RSTLIBF/EXPFPOR) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL1)
             CALL       PGM(UT416L1)
 SKIPCAL1:   CHKOBJ     OBJ(&RSTLIBF/NLICENSE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL2)
             CHKOBJ     OBJ(&RSTLIBF/LICENSE) OBJTYPE(*FILE) MBR(*NONE )
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL2)
             CALL       PGM(UT416L2)
 SKIPCAL2:   CHKOBJ     OBJ(&RSTLIBF/NLOG200) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL3)
             CHKOBJ     OBJ(&RSTLIBF/LOG200) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL3)
             CALL       PGM(UT416L3)
 SKIPCAL3:   CHKOBJ     OBJ(&RSTLIBF/NPORCV) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL4)
             CHKOBJ     OBJ(&RSTLIBF/PORCV) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL4)
             CALL       PGM(UT416L4)
 SKIPCAL4:   CHKOBJ     OBJ(&RSTLIBF/NWORKPUT) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL5)
             CHKOBJ     OBJ(&RSTLIBF/WORKPUT) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL5)
             CALL       PGM(UT416L5)
 SKIPCAL5:   CHKOBJ     OBJ(&RSTLIBF/NWRKSTGP) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL6)
             CHKOBJ     OBJ(&RSTLIBF/WRKSTGP) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPCAL6)
             CALL       PGM(UT416L6)
 SKIPCAL6:

/*  Delete Regular files   */
             CHKOBJ     OBJ(&RSTLIBF/EXPFPOR) OBJTYPE(*FILE) MBR(*NONE )
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDELR1)
             DLTF       FILE(&RSTLIBF/EXPFPOR)
 SKIPDELR1:  CHKOBJ     OBJ(&RSTLIBF/LICENSE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDELR2)
             DLTF       FILE(&RSTLIBF/LICENSE)
 SKIPDELR2:  CHKOBJ     OBJ(&RSTLIBF/LOG200) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDELR3)
             DLTF       FILE(&RSTLIBF/LOG200)
 SKIPDELR3:  CHKOBJ     OBJ(&RSTLIBF/PORCV) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDELR4)
             DLTF       FILE(&RSTLIBF/PORCV)
 SKIPDELR4:  CHKOBJ     OBJ(&RSTLIBF/WORKPUT) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDELR5)
             DLTF       FILE(&RSTLIBF/WORKPUT)
 SKIPDELR5:  CHKOBJ     OBJ(&RSTLIBF/WRKSTGP) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDELR6)
             DLTF       FILE(&RSTLIBF/WRKSTGP)
 SKIPDELR6:  CHKOBJ     OBJ(&RSTLIBF/ER331) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDELR7)
             DLTF       FILE(&RSTLIBF/ER331)
 SKIPDELR7:  CHKOBJ     OBJ(&RSTLIBF/ER341) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDELR8)
             DLTF       FILE(&RSTLIBF/ER341)
 SKIPDELR8:  CHKOBJ     OBJ(&RSTLIBF/PT331) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDELR9)
             DLTF       FILE(&RSTLIBF/PT331)
 SKIPDELR9:

/*  Copy Nfiles to perm files */
          CPYF  FROMFILE(&RSTLIBF/NEXPFPOR) +
                TOFILE(&RSTLIBF/EXPFPOR) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/NLICENSE) +
                TOFILE(&RSTLIBF/LICENSE) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/NLOG200) +
                TOFILE(&RSTLIBF/LOG200) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/NPORCV) +
                TOFILE(&RSTLIBF/PORCV) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/NWORKPUT) +
                TOFILE(&RSTLIBF/WORKPUT) CRTFILE(*YES)
          CPYF  FROMFILE(&RSTLIBF/NWRKSTGP) +
                TOFILE(&RSTLIBF/WRKSTGP) CRTFILE(*YES)
          RNMOBJ   OBJ(&RSTLIBF/N.ER331) OBJTYPE(*FILE) +
                NEWOBJ(ER331)
 /*       CPYF  FROMFILE(&RSTLIBF/NER331) +            */
 /*             TOFILE(&RSTLIBF/ER331) CRTFILE(*YES)   */
 /*       CPYF  FROMFILE(&RSTLIBF/NER341) +            */
 /*             TOFILE(&RSTLIBF/ER341) CRTFILE(*YES)   */
 /*       CPYF  FROMFILE(&RSTLIBF/NPT331) +            */
 /*             TOFILE(&RSTLIBF/PT331) CRTFILE(*YES)   */

/* Create logical file.      */

             CHKOBJ     OBJ(&RSTLIBF/LICENSE1) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/LICENSE1) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO

             CHKOBJ     OBJ(&RSTLIBF/PORCV1) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/PORCV1) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO

             CHKOBJ     OBJ(&RSTLIBF/PORCV2) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/PORCV2) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO

             CHKOBJ     OBJ(&RSTLIBF/PORCV3) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/PORCV3) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO

             CHKOBJ     OBJ(&RSTLIBF/PODTL3) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/PODTL3) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO

             CHKOBJ     OBJ(&RSTLIBF/WORKPUT1) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/WORKPUT1) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO

             CHKOBJ     OBJ(&RSTLIBF/WORKPUT2) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/WORKPUT2) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO

             CHKOBJ     OBJ(&RSTLIBF/WRKSTGP1) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/WRKSTGP1) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO

             CHKOBJ     OBJ(&RSTLIBF/WRKSTGP2) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/WRKSTGP2) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO


/*  Delete N. and N files   */
             CHKOBJ     OBJ(&RSTLIBF/NEXPFPOR) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL11)
             DLTF       FILE(&RSTLIBF/NEXPFPOR)
 SKIPDEL11:  CHKOBJ     OBJ(&RSTLIBF/NLICENSE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL12)
             DLTF       FILE(&RSTLIBF/NLICENSE)
 SKIPDEL12:  CHKOBJ     OBJ(&RSTLIBF/NLOG200) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL13)
             DLTF       FILE(&RSTLIBF/NLOG200)
 SKIPDEL13:  CHKOBJ     OBJ(&RSTLIBF/NPORCV) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL14)
             DLTF       FILE(&RSTLIBF/NPORCV)
 SKIPDEL14:  CHKOBJ     OBJ(&RSTLIBF/NWORKPUT) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL15)
             DLTF       FILE(&RSTLIBF/NWORKPUT)
 SKIPDEL15:  CHKOBJ     OBJ(&RSTLIBF/NWRKSTGP) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL16)
             DLTF       FILE(&RSTLIBF/NWRKSTGP)
       /*    DLTF       FILE(&RSTLIBF/NER331)     */
       /*    DLTF       FILE(&RSTLIBF/NER341)     */
       /*    DLTF       FILE(&RSTLIBF/NPT331)     */
 SKIPDEL16:  CHKOBJ     OBJ(&RSTLIBF/N.EXPFPOR) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL17)
             DLTF       FILE(&RSTLIBF/N.EXPFPOR)
 SKIPDEL17:  CHKOBJ     OBJ(&RSTLIBF/N.LICENSE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL18)
             DLTF       FILE(&RSTLIBF/N.LICENSE)
 SKIPDEL18:  CHKOBJ     OBJ(&RSTLIBF/N.LOG200) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL19)
             DLTF       FILE(&RSTLIBF/N.LOG200)
 SKIPDEL19:  CHKOBJ     OBJ(&RSTLIBF/N.PORCV) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL20)
             DLTF       FILE(&RSTLIBF/N.PORCV)
 SKIPDEL20:  CHKOBJ     OBJ(&RSTLIBF/N.WORKPUT) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL21)
             DLTF       FILE(&RSTLIBF/N.WORKPUT)
 SKIPDEL21:  CHKOBJ     OBJ(&RSTLIBF/N.WRKSTGP) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL22)
             DLTF       FILE(&RSTLIBF/N.WRKSTGP)
 SKIPDEL22:  CHKOBJ     OBJ(&RSTLIBF/N.ER331) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL23)
             DLTF       FILE(&RSTLIBF/N.ER331)
 SKIPDEL23:  CHKOBJ     OBJ(&RSTLIBF/N.ER341) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL24)
             DLTF       FILE(&RSTLIBF/N.ER341)
 SKIPDEL24:  CHKOBJ     OBJ(&RSTLIBF/N.PT331) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL25)
             DLTF       FILE(&RSTLIBF/N.PT331)
 SKIPDEL25:

 GETOUT:
/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
