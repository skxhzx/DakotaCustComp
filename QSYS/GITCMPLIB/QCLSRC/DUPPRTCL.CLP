/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DUPPRTCL  Duplicate print spool output                           */
/*  28 June, 2001                                                    */
/*  Roxanne Harrison                                                 */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    01/07/02  RH   4.16                                            */
/*      - Add MONMSG.                                                */
/*                                                                   */
/*    05/17/16  MLB  7.00                                            */
/*      - Fix: Revised pgm to use cmd DUPSPLFBFC instead of DUPSPLF. */
/*        Was causing conflict at client site due to cmd parm        */
/*        differences. (Y.Hata)                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 DUPPRTCL:   PGM    PARM(&FILE &JOBN &USER &JOB &OUTQ &OQLIB +
                        &SPLNBR &COPIES &NEWNAM &DLTOLD)
/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/
             DCL        VAR(&FILE)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBN)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&OUTQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&OQLIB)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&SPLNBR)     TYPE(*CHAR) LEN(6)
             DCL        VAR(&COPIES)     TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&NEWNAM)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&DLTOLD)     TYPE(*CHAR) LEN(4)
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             DUPSPLFBFC    FILE(&FILE) JOB(&JOBN/&USER/&JOB) +
                          OUTQ(&OQLIB/&OUTQ) SPLNBR(&SPLNBR) +
                          COPIES(&COPIES) NEWNAME(&NEWNAM) +
                          DLTOLDSPLF(&DLTOLD)                     /* (700 M) */
             MONMSG     MSGID(CPF3309)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
