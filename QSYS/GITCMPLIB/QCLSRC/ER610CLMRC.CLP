/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER610CLMRC   Task Summary by Employee - MRC version              */
/*  13 October 2009                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    10/13/09  DAS  6.10                                            */
/*      - Created                                                    */
/*                                                                   */
/*  ER610 Revisions                                                  */
/*    09/18/97  HNK  4.16                                            */
/*      - Created                                                    */
/*    09/25/02  MLB  4.16a                                           */
/*      - Added warehouse on call to pgm ER610                       */
/*      - Added warehouse on call to pgm ER610B                      */
/*      - Added from/to time on call to pgm ER610,ER611A,ER611.      */
/*      - Revised QRYSLT to include from/to time in selection.       */
/*    07/08/04  HNK  4.17a                                           */
/*      - Added &PBTIM and &PETIM parms to call ER611A               */
/*    08/18/04  HNK  4.17b                                           */
/*      - Include Tran# and Slot number to key for query file.       */
/*    09/02/04  HNK  4.17c                                           */
/*      - Added &FILE2 and &MEMBER2. Get unique member for &FILE2    */
/*      - Delete override for &FILE2 at the end.                     */
/*      - Remove members for &FILE and &FILE2 at the end.            */
/*                                                                   */
/*    02/17/06  MLB  5.00                                            */
/*      - Fix: Revised program to move RCLRSC cmd after              */
/*        GETOUT tag. Cleanup wasn't being done when user exited     */
/*        from options program, ER610.                               */
/*                                                                   */
/*    04/18/08  RBD  5.20                                            */
/*      - Include TASK, TO SLOT, and ITEM in query file key; used in */
/*        ER611A when counting replenishment transactions, to avert  */
/*        scamming tactics where user creates multiple trans         */
/*        for replenishment transfer of same item, same from & to    */
/*        slots.                                                     */
/*    06/10/09  GJA  5.20a                                           */
/*      - Enh:  incorporate LABELDO if using voice, remove OPNQRY    */
/*    10/09/09  GJA  6.10                                            */
/*      - Enh:  Cleaned up and revamped for suspended transactions   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER610CLMRC: PGM        PARM(&PWHSE &PUSER &PEMP# &PSHIFT &PCREW &PFMDT +
                          &PBTIM &PTODT &PETIM &PVYN &MRG &SESSID &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(ER611A)

             DCL        VAR(&FILE3) TYPE(*CHAR) LEN(10) VALUE(ER611)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
 /* 417c */
             DCL        VAR(&MEMBER2) TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER3)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PSHIFT)     TYPE(*CHAR) LEN(6)
             DCL        VAR(&PCREW)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PFMDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTODT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PEMP#)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PENDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PBTIM)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PETIM)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PUSER)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SESSID)     TYPE(*CHAR) LEN(40)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
/*5.20a*/    DCL        VAR(&PVYN)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*    Add EPM Demo libary                             */

             ADDLIBLE   LIB(PIREPM600F)

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER)
                ENDDO

             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)

/*    - Get unique member to use.                     */  /* 417c */
/*    - Override file to use unique member.           */  /* 417c */

             IF (&MEMBER3 = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE3 &MEMBER3)
                ENDDO

             OVRDBF     FILE(&FILE3) MBR(&MEMBER3) SHARE(*YES)

/*  Otherwise, run program. */

 REFRESH:
             RMVMSG     CLEAR(*ALL)

/*  Clear Work file. */

             CLRPFM     FILE(ER611A) MBR(&MEMBER)
             CLRPFM     FILE(ER611) MBR(&MEMBER)

 REPORT:

             RMVMSG     CLEAR(*ALL)

             CALL       PGM(ER610A) PARM(&PFMDT &PTODT &PBTIM &PETIM +
                          &PVYN &PEMP# &PWHSE &PCREW &MRG)

             CALL       PGM(ER611A) PARM(&PFMDT &PTODT &PBTIM &PETIM +
                          &MRG)

             CALL       PGM(ER611B) PARM(&PWHSE &PEMP# &PCREW &PFMDT +
                          &PTODT &PBTIM &PETIM)                    /* (416a) */

             CALL       PGM(ER611MRC) PARM(&PWHSE &PUSER &PFMDT &PBTIM +
                           &PTODT &PETIM &PSHIFT &PCREW &MRG &SESSID)

/*  Clean up before leaving */

             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:
             RCLRSC     LVL(*CALLER)                               /* (500 M) */
             DLTOVR     FILE(&FILE)
             MONMSG     MSGID(CPF9841)                             /* (416a) */
             DLTOVR     FILE(&FILE3)                               /* 417c */
             MONMSG     MSGID(CPF9841)                             /* 417c */

             IF         COND(&MEMBER *NE ' ') THEN(DO)
             RMVM       FILE(&FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF7301 CPF7310)
             ENDDO

             IF         COND(&MEMBER3 *NE ' ') THEN(DO)
             RMVM       FILE(&FILE3) MBR(&MEMBER3)
             MONMSG     MSGID(CPF320A CPF7301 CPF7310)
             ENDDO

/*   Remove EPM Demo libary  */

             RMVLIBLE   LIB(PIREPM600F)

             GOTO       NOMSG

 NEXTMSG:
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             CHGVAR     VAR(&RETURN) VALUE(&MSGID)
 NOMSG:

             ENDPGM
