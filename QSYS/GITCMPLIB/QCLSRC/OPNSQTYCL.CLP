/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OPNSQTYCL  Calculate open slot quantities                        */
/*  24 April 2001                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    04/24/01  DAS  4.15                                            */
/*      - Created                                                    */
/*                                                                   */
/*    03/22/04  DAS  4.17                                            */
/*      - Rewritten to not use OPNQRYF.                              */
/*      - Logic moved into RPG program, which was converted to SQL.  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OPNSQTYCL:  PGM        PARM(&WHSE &WHDP &DISP &QALC1 &QALC2 &QALC3 +
                          &QTFR1 &QTFR2 &QTFR3 &QPCK1 &QPCK2 &QPCK3 +
                          &QRCV1 &QRCV2 &QRCV3 &QUNK1 &QUNK2 &QUNK3)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&QALC1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QALC2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QALC3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QPCK1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QPCK2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QPCK3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QRCV1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QRCV2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QRCV3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QTFR1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QTFR2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QTFR3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QUNK1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QUNK2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QUNK3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(OPNSQTY) PARM(&WHSE &WHDP &DISP &QALC1 +
                          &QALC2 &QALC3 &QTFR1 &QTFR2 &QTFR3 &QPCK1 +
                          &QPCK2 &QPCK3 &QRCV1 &QRCV2 &QRCV3 &QUNK1 +
                          &QUNK2 &QUNK3)

             RCLRSC     *CALLER

             ENDPGM
