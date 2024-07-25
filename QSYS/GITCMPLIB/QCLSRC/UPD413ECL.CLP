/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UPD413ECL  Add JOBSCDE to Jobq-QBATCH for tracking log cleanup   */
/*  25 February 2000                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   03/07/00  DAS  4.13                                             */
/*     - Revised command to use job description PIRJOBD.             */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Notes:   Definition of the four parms on JOBSCDE command are:    */
/*             - '*BATCH' - Tells program running from JOBQ.         */
/*             - '001' - Warehouse number. Entry added for each      */
/*                       warehouse entry in file WAREHS.             */
/*             - ' '   - Number of Days to keep Receiving Logs.      */
/*             - ' '   - Number of Days to keep Picking Logs.        */
/*           Note Number of Days values defined above are blank      */
/*           since this will cause the default day values to be      */
/*           retrieved from the OPTIONS file when the program is run.*/
/*                                                                   */
/*-------------------------------------------------------------------*/

 UPD413ECL:   PGM

/*-------------------------------------------------------------------*/
/*  File declarations                                                */
/*-------------------------------------------------------------------*/

             DCLF       FILE(WAREHS)

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
             DCL        VAR(&WHSEA) TYPE(*CHAR) LEN(3)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

#TOP:

             RCVF
             MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(#ENDWHS))

             CHGVAR     VAR(&WHSEA) VALUE(&WHCODE)

             ADDJOBSCDE JOB(PO760CL) CMD(CALL PGM(PO760CL) +
                          PARM('*BATCH' &WHSEA ' ' ' ')) +
                          FRQ(*WEEKLY) SCDDATE(*NONE) SCDDAY(*ALL) +
                          SCDTIME(013000) JOBD(PIR/PIRJOBD) +
                          USER(QSECOFR) MSGQ(*NONE) TEXT('FS-WMS +
                          Receiving/Pick Tracking Log Cleanup')
             GOTO       CMDLBL(#TOP)

#ENDWHS:


             ENDPGM
