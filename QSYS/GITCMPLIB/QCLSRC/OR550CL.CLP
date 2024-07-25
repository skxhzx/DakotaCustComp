/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR550CL   Route loading sheet                                    */
/*  09 October, 1994                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    12/09/94  DAS                                                  */
/*      - Ignoring LBITEM = '*PIRPICK'                               */
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

OR550CL:    PGM        PARM(&CMD &BATCH &WHSE &RTE &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&BATCH)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&BATCHA)     TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
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
                 '*AND LBRTE  *EQ ' *CAT +
                           &QUOTE *CAT &RTE *CAT &QUOTE *BCAT +
                 '*AND (LBTYPE *EQ ' *CAT +
                           &QUOTE *CAT 'O' *CAT &QUOTE *BCAT +
                       '*OR LBTYPE *EQ ' *CAT +
                          &QUOTE *CAT 'B' *CAT &QUOTE *CAT ')' *BCAT +
                 '*AND LBITEM *NE ' *CAT +
                           &QUOTE *CAT '*PIRPICK' *CAT &QUOTE)

   /* Use OPNQRYF to create stop summary file. */

             OVRDBF     FILE(OR550) TOFILE(LABEL3) SHARE(*YES)
             OPNQRYF    FILE((LABEL3)) +
                        FORMAT(OR550) +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((LBPBAT) (LBWHSE) (LBRTE) +
                               (LBSTOP) (LBWHDP)) +
                        GRPFLD(LBPBAT LBWHSE LBRTE LBSTOP LBWHDP +
                               LBORD OHCUST OHCNAM) +
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

             CALL       PGM(OR550) PARM(&CMD &BATCH &WHSE &RTE)

   /* Clean up before leaving */

             DLTOVR     FILE(OR550)
             RCLRSC

             ENDPGM
