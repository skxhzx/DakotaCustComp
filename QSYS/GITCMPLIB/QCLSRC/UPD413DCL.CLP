/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UPD413DCL  Add JOBSCDE to Jobq-QBATCH for Day-End processing.    */
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
/*  Notes:   Definition of two parms on JOBSCDE command are:         */
/*             - '001' - Warehouse number. Defaults to 001.          */
/*             - 'Y'   - Run in Batch. Must be 'Y' for this entry.   */
/*           This program must be run once for each active warehouse */
/*           configured in FS-WMS. Then using CHGJOBSCDE the ware-   */
/*           house number must be changed in each entry.             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UPD413DCL:   PGM

/*-------------------------------------------------------------------*/
/*  File declarations                                                */
/*-------------------------------------------------------------------*/

             DCLF       FILE(WAREHS)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE('    ')
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(10) VALUE(UPD413DCL)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD) TYPE(*CHAR) LEN(256)
             DCL        VAR(&CMD2) TYPE(*CHAR) LEN(256)
             DCL        VAR(&CMD3) TYPE(*CHAR) LEN(256)
             DCL        VAR(&WHSEA) TYPE(*CHAR) LEN(3)
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

#TOP:

             RCVF
             MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(#ENDWHS))

             CHGVAR     VAR(&WHSEA) VALUE(&WHCODE)

             ADDJOBSCDE JOB(IT500CL) CMD(CALL PGM(IT500CL) +
                          PARM(&WHSEA 'Y')) FRQ(*WEEKLY) +
                          SCDDATE(*NONE) SCDDAY(*ALL) +
                          SCDTIME(053000) JOBD(PIR/PIRJOBD) +
                          USER(QSECOFR) MSGQ(*NONE) TEXT('FS-WMS +
                          End of Day Processing')
             GOTO       CMDLBL(#TOP)

#ENDWHS:

             ENDPGM
