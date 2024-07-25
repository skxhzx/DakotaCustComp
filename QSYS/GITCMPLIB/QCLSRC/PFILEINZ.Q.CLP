/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PFILEINZ  Truck build picking labels - Export file init          */
/*  30 August 2000                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    8/30/00  DAS  4.14                                             */
/*     - Created                                                     */
/*                                                                   */
/*    9/19/00  DAS  QLT                                              */
/*     - Special mod for Quality.                                    */
/*     - Revised to use static member name of Lnnn, where nnn is     */
/*       the warehouse code.                                         */
/*     - Changed to not clear member if it exists.                   */
/*      - * IMPORTANT * It is assumed that the script has            */
/*        '* NO EXPORT *' in it because the actual FTP is done with  */
/*        a separate program created by Dan. This revision allows    */
/*        multiple routes to go into a single member. Program        */
/*        RH130A has been modified to make sure that Dan's FTP       */
/*        process is not running when trying to pick & print.        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*   Input                                                           */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &RTE    -  Host route                                          */
/*                                                                   */
/*   Output                                                          */
/*                                                                   */
/*    &MBR    -  Member name                                         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will create/cleare a member in the export file.    */
/*   The member name to be used is the host route name.              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PFILEINZ:   PGM        PARM(&WHSE &RTE &MBR)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPLBL')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Create member name */

         /*  CHGVAR     VAR(&MBR) VALUE('L' *CAT %SST(&WHSE 2 2) +  QLT D */
         /*               *CAT &RTE)                                QLT D */
             CHGVAR     VAR(&MBR) VALUE('L' *CAT &WHSE)          /* QLT M */

/* Create/Clear member in export file */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILE) +
                          MBR(&MBR))
       /*    CLRPFM     FILE(&FILE) MBR(&MBR)     QLT D */

             ENDPGM
