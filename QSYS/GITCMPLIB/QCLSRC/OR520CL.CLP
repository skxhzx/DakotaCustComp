/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR520CL   Pick orders - Build pallets                            */
/*  20 September, 1994                                               */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/22/96  DAS  2.13                                            */
/*      - Added $OTYPE to parameters.                                */
/*                                                                   */
/*  Notes:                                                           */
/*                                                                   */
/*    The OPNQRYF statement is used to create a stop summary file.   */
/*    A stop summary record contains total fixed pieces/cube/weight  */
/*    and total PIR pieces/cube/weight.  OPNQRYF is very good at     */
/*    summarizing records but does not allow conditional MAPFLD      */
/*    expressions (ie. IF LBSTYP = 'P' THEN OQPCUB = SUM(LBCUBE)).   */
/*    To get around this limitation a numeric field was added to     */
/*    the label file which is set to 0 for fixed items and 1 for     */
/*    PIR items. Now a calculation can be performed to do the IF     */
/*    expression.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

OR520CL:    PGM        PARM(&BATCH &WHSE &OTYPE &RTE &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&BATCH)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&BATCHA)     TYPE(*CHAR) LEN(7)
             DCL        VAR(&OTYPE)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&Q)          TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

             CHGVAR     VAR(&BATCHA) VALUE(&BATCH)
             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBPBAT *EQ ' *CAT &BATCHA *BCAT +
                  '*AND LBWHSE *EQ ' *CAT &WHSEA *BCAT +
                  '*AND LBRTE  *EQ ' *CAT &Q *CAT &RTE *CAT &Q *BCAT +
                  '*AND LBTYPE *EQ ' *CAT &Q *CAT 'O' *CAT &Q)

   /* Use OPNQRYF to create stop summary file. */

             OVRDBF     FILE(OR520) TOFILE(LABEL) SHARE(*YES)
             OPNQRYF    FILE((LABEL)) +
                        FORMAT(OR520) +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((LBPBAT) (LBWHSE) (LBRTE) +
                               (LBWHDP) (LBSTOP *DESCEND)) +
                        GRPFLD(LBPBAT LBWHSE LBRTE LBWHDP LBSTOP) +
                        MAPFLD((MFTEMP 'LBQRYF - 1') +
                               (FIXMULT '%ABSVAL(MFTEMP)') +
                               (MFFPCS 'LBQALC * FIXMULT') +
                               (MFFCUB 'LBCUBE * FIXMULT') +
                               (MFFWGT 'LBSWGT * FIXMULT') +
                               (MFPPCS 'LBQALC * LBQRYF') +
                               (MFPCUB 'LBCUBE * LBQRYF') +
                               (MFPWGT 'LBSWGT * LBQRYF') +
                               (OQFPCS '%SUM(MFFPCS)') +
                               (OQFCUB '%SUM(MFFCUB)') +
                               (OQFWGT '%SUM(MFFWGT)') +
                               (OQPPCS '%SUM(MFPPCS)') +
                               (OQPCUB '%SUM(MFPCUB)') +
                               (OQPWGT '%SUM(MFPWGT)')) +
                        OPTIMIZE(*ALLIO) +
                        SEQONLY(*YES)

/*  Call program to build pallets. */

             CALL       PGM(OR520) PARM(&BATCH &WHSE &OTYPE &RTE)

   /* Clean up before leaving */

             DLTOVR     FILE(OR520)
             RCLRSC

             ENDPGM
