/* TAASPLDC - Duplicate spool file - CPP for DUPSPLF              */
             PGM        PARM(&FILE &FULLJOB &PRTFILE &OUTQ &SPLNBR +
                          &COPIES &NEWSPLF &DLTOLDSPLF)
             DCL        &FULLJOB *CHAR LEN(26)
             DCL        &JOB *CHAR LEN(10)
             DCL        &USER *CHAR LEN(10)
             DCL        &JOBNBR *CHAR LEN(6)
             DCL        &FILE *CHAR LEN(10)
             DCL        &NEWSPLF *CHAR LEN(10)
             DCL        &NEWNAME *CHAR LEN(10)
             DCL        &PRTFILE *CHAR LEN(20)
             DCL        &PRTFILEN *CHAR LEN(10)
             DCL        &PRTFILEL *CHAR LEN(10)
             DCL        &OUTQ *CHAR LEN(20)
             DCL        &OUTQN *CHAR LEN(10)
             DCL        &OUTQL *CHAR LEN(10)
             DCL        &SPLNBR *CHAR LEN(6)
             DCL        &COPIES *DEC LEN(3 0)
             DCL        &DLTOLDSPLF *CHAR LEN(4)
             DCL        &ERRORSW *LGL                     /* Std err */
             DCL        &MSGID *CHAR LEN(7)               /* Std err */
             DCL        &MSGDTA *CHAR LEN(100)            /* Std err */
             DCL        &MSGF *CHAR LEN(10)               /* Std err */
             DCL        &MSGFLIB *CHAR LEN(10)            /* Std err */
             DCL        &KEYVAR *CHAR LEN(4)              /* Std err */
             MONMSG     MSGID(CPF0000) EXEC(GOTO STDERR1) /* Std err */
             CHGVAR     &PRTFILEN %SST(&PRTFILE 1 10)  /* Extt file */
             CHGVAR     &PRTFILEL %SST(&PRTFILE 11 10) /* Ext lib */
             CHGVAR     &OUTQN  %SST(&OUTQ 1 10)  /* Extract OUTQ */
             CHGVAR     &OUTQL  %SST(&OUTQ 11 10) /* Extract lib */
             CHGVAR     &JOB    %SST(&FULLJOB 1 10)  /* Extract job */
             CHGVAR     &USER   %SST(&FULLJOB 11 10) /* Extract user */
             CHGVAR     &JOBNBR %SST(&FULLJOB 21  6) /* Ext job nbr */
             CHGVAR     &NEWNAME &NEWSPLF /* Assume diff name */
             IF         (&NEWSPLF *EQ '*PRTFILE') DO /* If same name */
             CHGVAR     &NEWNAME &PRTFILEN
             ENDDO      /* If same name */
             IF         (&NEWSPLF *EQ '*FILE') DO /* Use file name */
             CHGVAR     &NEWNAME &FILE
             ENDDO      /* Use file name */
             CHKOBJ     QTEMP/DUPSPLP *FILE /* Check for temp PF */
             MONMSG     MSGID(CPF9801) EXEC(DO) /* Does not exist */
             RCVMSG     MSGTYPE(*EXCP) /* Remove escape message */
             CRTPF      FILE(QTEMP/DUPSPLP) RCDLEN(199) SIZE(*NOMAX) +
                          /* Create file */
             ENDDO      /* Does not exist */
             IF         COND(&FULLJOB *EQ '*') THEN(CPYSPLF +
                          FILE(&FILE) TOFILE(QTEMP/DUPSPLP) +
                          SPLNBR(&SPLNBR) CTLCHAR(*FCFC)) /*   Copy +
                          to temp PF */
             ELSE       DO  /* Specific job name used */
             IF         (&USER *EQ '  ') CHGVAR &USER '*N'
             IF         (&JOBNBR *EQ '  ') CHGVAR &JOBNBR '*N'
             CPYSPLF    FILE(&FILE) TOFILE(QTEMP/DUPSPLP) +
                          JOB(&JOBNBR/&USER/&JOB) SPLNBR(&SPLNBR) +
                          CTLCHAR(*FCFC) /* Copy to temp  PF */
             ENDDO      /* Specific job name used */
                        /* Use named OUTQ, FCFC and COPIES */
             IF         (&OUTQN *EQ '*PRTFILE') DO /* *PRTFILE */
             OVRPRTF    FILE(QSYSPRT) TOFILE(&PRTFILEL/&PRTFILEN) +
                          CTLCHAR(*FCFC) COPIES(&COPIES) +
                          SPLFNAME(&NEWNAME)
             ENDDO      /* *PRTFILE */
             ELSE       DO /* Not *PRTFILE */
             OVRPRTF    FILE(QSYSPRT) TOFILE(&PRTFILEL/&PRTFILEN) +
                          CTLCHAR(*FCFC) OUTQ(&OUTQL/&OUTQN) +
                          COPIES(&COPIES) SPLFNAME(&NEWNAME)
             ENDDO      /* Not *PRTFILE */
             CPYF       QTEMP/DUPSPLP TOFILE(QSYSPRT) /* Dup file */
             IF         (&DLTOLDSPLF *EQ '*NO') DO /* No delete */
             SNDPGMMSG  MSG('Spool file ' *CAT &FILE *TCAT ' +
                          duplicated.') MSGTYPE(*COMP)
             ENDDO      /* No delete */
             IF         (&DLTOLDSPLF *EQ '*YES') DO /* Dlt old */
             IF         (&FULLJOB *EQ '*') DO /* Same job */
             DLTSPLF    FILE(&FILE) JOB(*) SPLNBR(&SPLNBR)
             MONMSG     MSGID(CPF3303)                    /* 4.17    */
             ENDDO      /* Same job */
             ELSE       DO /* Qualified job name */
             DLTSPLF    FILE(&FILE) JOB(&JOBNBR/&USER/&JOB) +
                          SPLNBR(&SPLNBR)
             MONMSG     MSGID(CPF3303)                    /* 4.17    */
             ENDDO      /* Qualified job name */
             SNDPGMMSG  MSG('Spool file ' *CAT &FILE *TCAT ' +
                          duplicated and old spooled file +
                          deleted.') MSGTYPE(*COMP)
             ENDDO      /* Dlt old */
             RETURN     /* Normal end of program */
 STDERR1:               /* Standard error handling routine */
             IF         &ERRORSW SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE) /* Func chk */
             CHGVAR     &ERRORSW '1' /* Set to fail if error occurs */
 STDERR2:    RCVMSG     MSGTYPE(*DIAG) RMV(*NO) KEYVAR(&KEYVAR) +
                          MSGDTA(&MSGDTA) MSGID(&MSGID) MSGF(&MSGF) +
                          SNDMSGFLIB(&MSGFLIB)
             IF         (&KEYVAR *EQ '    ') GOTO STDERR3
             RMVMSG     MSGKEY(&KEYVAR)
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
             GOTO       STDERR2 /* Loop back for addl diagnostics */
 STDERR3:    RCVMSG     MSGTYPE(*EXCP) MSGDTA(&MSGDTA) MSGID(&MSGID) +
                          MSGF(&MSGF) SNDMSGFLIB(&MSGFLIB)
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*ESCAPE)
             ENDPGM
