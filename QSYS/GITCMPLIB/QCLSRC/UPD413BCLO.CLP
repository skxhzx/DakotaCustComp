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
                          PARM('*BATCH' 'xxx' '4' '4')) +
                          FRQ(*WEEKLY) SCDDATE(*NONE) SCDDAY(*ALL) +
                          SCDTIME(013000) TEXT('FS-WMS +
                          Receiving/Pick Tracking Log Cleanup')

             ENDPGM
