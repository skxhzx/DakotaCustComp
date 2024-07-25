/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR620CL   Truck build - Build pallets                            */
/*  20 June 1997                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    06/20/97  DAS  4.00                                            */
/*      - Major revisions for truck build process.  This program is  */
/*        based on OR520CL. Old revisions were removed to clean      */
/*        up program.                                                */
/*                                                                   */
/*                                                                   */
/*    07/13/16  TAB  7.00a                                           */
/*      - Added call tp DFPICK before calling OR620. New parm for    */
/*      - PrePalletBld will be passed to DFPICK....                  */
/*                                                                   */
/*    06/07/18  DAS  7.20a                                           */
/*      - Revised to monitor for message CPF108B/CPF180C for RCLRSC. */
/*        When called via DragDrop 2, sometimes this program would   */
/*        end up in a secondary thread. As of v7r1, the above error  */
/*        is thrown when that happens because RCLRSC is not thread   */
/*        safe.                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

OR560CL:    PGM        PARM(&BATCH &WHSE &TRUCK &OTYPE &RTEID &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&BATCH)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&BATCHA)     TYPE(*CHAR) LEN(7)
             DCL        VAR(&OTYPE)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&Q)          TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&RTEID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&TRUCK)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PPBLD)      TYPE(*CHAR) LEN(9) +
                        VALUE('PREPLTBLD')                 /* (7.00a) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Call program to zone combinations and zone generations */

             CALL       PGM(OR612) PARM(&BATCH &WHSE &TRUCK &RTEID)

/*  Call program to assign zones to slots */

             CALL       PGM(OR615) PARM(&BATCH &WHSE &TRUCK &OTYPE &RTEID)

/*  Call program DFPICK for PrePalletBuilds    */   /* 7.00a */

             CALL       PGM(DFPICK) PARM(&WHSE &RTEID &PPBLD)     /* 7.00a */

/*  Call program to build pallets. */

             CALL       PGM(OR620) PARM(&BATCH &WHSE &OTYPE &RTEID &TRUCK)

   /* Clean up before leaving */

             RCLRSC
             MONMSG     MSGID(CPF108B CPF180C)  /* 720aA */

             ENDPGM
