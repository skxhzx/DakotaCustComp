/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UPD413BCL  Add JOBSCDE to Jobq-QBATCH for tracking log cleanup   */
/*  10 November 1999                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   01/20/00  DAS  4.13                                             */
/*     - Revised command to use job description PIRJOBD, set user    */
/*       to QSYSOPR and message queue to *NONE so that only error    */
/*       messages will be sent.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UPD413BCL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE('    ')
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(10) VALUE(UPD413BCL)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             ADDJOBSCDE JOB(PO760CL) CMD(CALL PGM(PO760CL) +
                          PARM('*BATCH' '001' '4' '4')) +
                          FRQ(*WEEKLY) SCDDATE(*NONE) SCDDAY(*ALL) +
                          SCDTIME(050000) JOBD(PIR/PIRJOBD) +
                          USER(QSYSOPR) MSGQ(*NONE) TEXT('FS-WMS +
                          Receiving/Pick Tracking Log Cleanup')

             ENDPGM
