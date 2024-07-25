/* EXTLSTCL - CPP for EXTLST - Extracts list elements */
/*PARMS LOG(*NO)                                                    */
             PGM        PARM(&LIST &ELMLEN &ELEMENT &CURNBR +
                          &MULTILIST)
             DCL        &LIST *CHAR LEN(2000)
             DCL        &ELMLEN *DEC LEN(5 0)
             DCL        &CURNBR *DEC LEN(5 0)
             DCL        &ELEMENT *CHAR LEN(100)
             DCL        &MULTILIST *CHAR LEN(4)
             DCL        &WORK *CHAR LEN(2)
             DCL        &LSTCNT *DEC LEN(5 0)
             DCL        &LX *DEC LEN(5 0)
             DCL        &MX *DEC LEN(5 0)
             DCL        &ERRORSW *LGL                     /* Std err */
             DCL        &MSGID *CHAR LEN(7)               /* Std err */
             DCL        &MSGDTA *CHAR LEN(100)            /* Std err */
             DCL        &MSGF *CHAR LEN(10)               /* Std err */
             DCL        &MSGFLIB *CHAR LEN(10)            /* Std err */
             MONMSG     MSGID(CPF0000) EXEC(GOTO STDERR1) /* Std err */
             CHGVAR     &WORK %SST(&LIST 1 2) /* Nbr of lists */
             CVTBINDEC  FROMBIN(&WORK) TODEC(&LSTCNT)
             IF         (&LSTCNT *LT &CURNBR) DO /* Out of bounds */
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGTYPE(*ESCAPE) +
                          MSGDTA('The CURNBR value exceeds the number +
                          of elements in the list')
             ENDDO      /* Out of bounds */
             IF         (&CURNBR *LT 0) DO /* Less than 0 */
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGTYPE(*ESCAPE) +
                          MSGDTA('The CURNBR value is less than 0')
             ENDDO      /* Less than 0 */
             IF         (&LSTCNT *EQ &CURNBR) DO /* End of list */
             CHGVAR     &CURNBR -1
             CHGVAR     &ELEMENT ' '
             GOTO       RETURN
             ENDDO      /* End of list */
             CHGVAR     &CURNBR (&CURNBR + 1) /* Next number in list */
                        /* Determine starting location */
             IF         (&MULTILIST *EQ '*NO') DO /* Simple list */
             CHGVAR     &LX ((&ELMLEN * &CURNBR) + (3 - &ELMLEN))
             ENDDO      /* Simple list */
             IF         (&MULTILIST *EQ '*YES') DO /* Multi list */
             CHGVAR     &MX ((2 * &CURNBR) + 1) /* Offset location */
             CHGVAR     &WORK %SST(&LIST &MX 2)
             CVTBINDEC  FROMBIN(&WORK) TODEC(&LX) /* Offset value */
             CHGVAR     &LX (&LX + 1) /* Starting loc of bin count */
             CHGVAR     &LX (&LX + 2)
             ENDDO      /* Multi list */
                        /* Extract element */
             CHGVAR     &ELEMENT %SST(&LIST &LX &ELMLEN)
 RETURN:     RETURN     /* Normal end of program */
 STDERR1:               /* Standard error handling routine */
             IF         &ERRORSW SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE) /* Func chk */
             CHGVAR     &ERRORSW '1' /* Set to fail ir error occurs */
 STDERR2:    RCVMSG     MSGTYPE(*DIAG) MSGDTA(&MSGDTA) MSGID(&MSGID) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         (&MSGID *EQ '       ') GOTO STDERR3
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
             GOTO       STDERR2 /* Loop back for addl diagnostics */
 STDERR3:    RCVMSG     MSGTYPE(*EXCP) MSGDTA(&MSGDTA) MSGID(&MSGID) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*ESCAPE)
             ENDPGM
