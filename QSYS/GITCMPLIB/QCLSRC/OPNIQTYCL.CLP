/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OPNIQTYCL  Calculate open item quantities                        */
/*  24 April 2001                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    04/24/01  DAS  4.15                                            */
/*      - Created                                                    */
/*                                                                   */
/*    12/14/11  GJA  6.40                                            */
/*      - Rewritten to use SQL instead of opnqry                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OPNIQTYCL:  PGM        PARM(&WHSE &ITEM &QALC1 &QALC2 &QALC3 +
                          &QHLD1 &QHLD2 &QHLD3 &QUNK1 &QUNK2 &QUNK3)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&QALC1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QALC2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QALC3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QHLD1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QHLD2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QHLD3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QUNK1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QUNK2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QUNK3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(OPNIQTY) PARM(&WHSE &ITEM &QALC1 &QALC2 +
                          &QALC3 &QHLD1 &QHLD2 &QHLD3 &QUNK1 &QUNK2 +
                          &QUNK3)

             RCLRSC     *CALLER

             ENDPGM
