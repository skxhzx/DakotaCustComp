/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT880CL   Validate Printer device                                */
/*  09 January, 2007                                                 */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    01/10/12  DAS  640a                                            */
/*      - Revised to accept QPRINT as a valid device.                */
/*                                                                   */
/*    07/17/18  MLB  7.20                                            */
/*      - Fix: Revised pgm to monitor for CPF26A7 in case device     */
/*        entered is not a type printer.                             */
/*                                                                   */
/*    04/22/19  MLB  7.30                                            */
/*      - Enh: Revised pgm to validate that output queue specified   */
/*        in zone template exists. If not, send error.               */
/*                                                                   */
/*    11/11/20  KDE  7.40                                            */
/*      - Enh: Revised return error if device blank                  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT880CL:    PGM        PARM(&DEVNAME &RTN)

             DCL        VAR(&DEVNAME) TYPE(*CHAR) LEN(10)
             DCL        VAR(&EXIST)   TYPE(*LGL)                  /* (730 A) */
             DCL        VAR(&RTN)     TYPE(*CHAR) LEN(8)

             DCL        VAR(&RCVVAR)  TYPE(*CHAR) LEN(3000)
             DCL        VAR(&RCVVARLEN) TYPE(*CHAR) LEN(4)
             DCL        VAR(&FMTNAME) TYPE(*CHAR) LEN(8) +
                          VALUE('DEVD1100')
             DCL        VAR(&ERRCODE) TYPE(*CHAR) LEN(8) +
                          VALUE(X'00000000')

/*           MONMSG     MSGID(CPF2702 CPF26A7)                    /* (730 D) */
             MONMSG     MSGID(CPF26A7)                            /* (730 M) */

  /* If deviced sent is blank return error  */                    /* (740 A) */
             IF COND(&DEVNAME *EQ ' ') THEN(DO)           /* (740 A) */
               CHGVAR VAR(&RTN) VALUE('*ERROR')           /* (740 A) */
               RETURN                                     /* (740 A) */
             ENDDO                                        /* (740 A) */

  /* Confirm either DEVICE or OUTQ          */                    /* (740 A) */
             CHKOBJ     OBJ(&DEVNAME) OBJTYPE(*OUTQ)       /* (740 A) */
             MONMSG     MSGID(CPD0078 CPF0001 CPF9801) EXEC(DO) /* +
                                                              (740 A) */
               CHKOBJ     OBJ(&DEVNAME) OBJTYPE(*DEVD)       /* (740 A) */
               MONMSG     MSGID(CPD0078 CPF0001 CPF9801) EXEC(DO) /* +
                            (740 A) */
                 CHGVAR VAR(&RTN) VALUE('*ERROR')            /* (740 A) */
                 RETURN                                      /* (740 A) */
             ENDDO                                         /* (740 A) */
             ENDDO                                         /* (740 A) */

  /* Accept QPRINT as a valid device  740a  */
             IF COND(&DEVNAME *EQ 'QPRINT') THEN(DO)
               CHGVAR VAR(&RTN) VALUE('*OK')
               RETURN
             ENDDO

             CHGVAR     VAR(%BIN(&RCVVARLEN)) VALUE(3000)

  /*  CALL QDCRDEVD TO RETRIEVE INFO ABOUT DEVNAME INPUT PARM */

             CALL       PGM(QDCRDEVD) PARM(&RCVVAR &RCVVARLEN +
                          &FMTNAME &DEVNAME &ERRCODE)
     MONMSG     MSGID(CPF2702) EXEC(DO)                           /* (730 M) */
/*             Check for valid output queue name.                    (730 A) */
               CHGVAR     VAR(&EXIST) VALUE('1')                  /* (730 A) */
               CHKOBJ     OBJ(&DEVNAME) OBJTYPE(*OUTQ)            /* (730 A) */
               MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                            VALUE('0')) /* Outq not found.           (730 A) */
                 IF         COND(*NOT &EXIST) THEN(DO)            /* (730 A) */
                   CHGVAR     VAR(&RCVVAR) VALUE(' ')             /* (730 A) */
                 ENDDO                                            /* (730 A) */
                 ELSE       CMD(DO)                               /* (730 A) */
                   CHGVAR     VAR(&RCVVAR) VALUE('*OK')           /* (730 A) */
                 ENDDO                                            /* (730 A) */
             ENDDO                                                /* (730 A) */

             CHGVAR     VAR(&RTN) VALUE('*OK    ')
             IF         COND(&RCVVAR *EQ ' ') THEN(CHGVAR +
                          VAR(&RTN) VALUE('*ERROR '))

             ENDPGM
