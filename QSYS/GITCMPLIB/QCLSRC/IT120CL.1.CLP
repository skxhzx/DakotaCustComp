/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT120CL   Inventory adjustments                                  */
/*  20 February 1993                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    11/08/06  JCJ  5.10                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: City Line                               */
/*                                                                   */
/*    11/08/06  JCJ  CLD                                             */
/*      - Add user authorization check.                              */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Graves Menu Maker                       */
/*                                                                   */
/*    08/20/12  RH   GMM                                             */
/*      - Add to authorization check.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Inter County Bakers                     */
/*                                                                   */
/*    04/24/12  RH   ICB                                             */
/*      - Add to authorization check.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: TPC                                     */
/*                                                                   */
/*    01/09/19  GJA  TPC                                             */
/*      - Add to authorization check.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Packer's Provision                      */
/*                                                                   */
/*    11/09/09  MLB  PAK                                             */
/*      - Add user authorization check.                              */
/*      - Added Packer's to CLD mod.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Halsey Foodservice                      */
/*                                                                   */
/*    08/25/12  MLB  HAL                                             */
/*      - Add user authorization check per Tim S. skype 08/07/12.    */
/*      - Added Halsey to CLD mod.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Greenleaf Produce                       */
/*    04/15/13  RH   GLPa                                            */
/*      - Add to authorization check                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Will Foods                              */
/*    09/22/14  RH   WILa                                            */
/*      - Add to authorization check                                 */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Kohl Wholesale                          */
/*                                                                   */
/*    08/11/14  LMC  KHL                                             */
/*      - Add to authorization check.                                */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Sofo Foods                              */
/*                                                                   */
/*    02/01/15  RH   SOFO                                            */
/*      - Add to authorization check.                                */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Fischer Foods                           */
/*    09/28/15  RH   FFC                                             */
/*      - Add to authorization check                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: European Imports                        */
/*                                                                   */
/*    01/28/15  MLB  EI   P#01308                                    */
/*      - Add to authorization check.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Marques Foods                           */
/*    06/25/18  RH   MQSa                                            */
/*      - Add to authorization check.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    08/09/18  MLB  DRY                                             */
/*      - Add to authorization check.                                */
/*      - Per Kelly R email dated 08.09.2018.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Liebrs Kosher Foods                     */
/*    11/15/19  RH   LKFa                                            */
/*      - Add to authorization check.                                */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Presto                                  */
/*                                                                   */
/*    06/07/18  GJA  PFCa                                            */
/*      - Add user authorization check per Dewey email  06/07/18.    */
/*      - Added Presto to CLD mod.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Foods Galore                            */
/*                                                                   */
/*    10/26/21  MLB  FGL  zd#5730                                    */
/*      - Add to authorization check.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dependable Food                         */
/*                                                                   */
/*    10/26/21  MLB  DFC  P#                                         */
/*      - Add to authorization check.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT120CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (510 A)  */

/*CLD A*/    DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINE  ')
/*ICB A*/    DCL        VAR(&ICB) TYPE(*CHAR) LEN(10) +
                          VALUE('ICB')
/*TPCaA*/    DCL        VAR(&TPC) TYPE(*CHAR) LEN(10) +
                          VALUE('TPC')
/*GMM A*/    DCL        VAR(&MENUMAKER) TYPE(*CHAR) LEN(10) +
                          VALUE('MENUMAKER ')
/*HAL A*/    DCL        VAR(&HALSEY) TYPE(*CHAR) LEN(10) +
                          VALUE('HALSEY')
/*PFCaA*/    DCL        VAR(&PRESTO) TYPE(*CHAR) LEN(10) +
                          VALUE('PRESTOFOOD')
             DCL        VAR(&PACKERS) TYPE(*CHAR) LEN(10) +
                          VALUE('PACKERS')                        /* (PAK A) */
/*GLP A*/    DCL        VAR(&GLP) TYPE(*CHAR) LEN(10) +
                          VALUE('GREENLEAF')
/*WIL A*/    DCL        VAR(&WIL) TYPE(*CHAR) LEN(10) +
                          VALUE('WILLFOODS')
/*KHL A*/    DCL        VAR(&KOHL) TYPE(*CHAR) LEN(10) +
                          VALUE('KOHL')
/*MQS A*/    DCL        VAR(&MQS) TYPE(*CHAR) LEN(10) +
                          VALUE('MARQUES')                        /* (MQS A) */
/*SOF A*/    DCL        VAR(&SOFO) TYPE(*CHAR) LEN(10) +
                          VALUE('SOFOFOODS')
/*FFC A*/    DCL        VAR(&FFC) TYPE(*CHAR) LEN(10) +
                          VALUE('FISCHER')
/*EI  A*/    DCL        VAR(&EUROIMPORT) TYPE(*CHAR) LEN(10) +
                          VALUE('EI')
             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND ')                     /* (DRY A) */
/*LKF A*/    DCL        VAR(&LKF) TYPE(*CHAR) LEN(10) +
                          VALUE('LIEBERS  ')
/*FGL A*/    DCL        VAR(&FGL) TYPE(*CHAR) LEN(10) +
                          VALUE('FOODSGALOR')

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(IT120)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

/* Informational message. */

/*CLD A*/    DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')

/*510 A*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
/*510 A*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*510 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*510 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*510 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */

/*510 A*/    CHGVAR     VAR(&PGMID) VALUE(IT120CL)
/*510 A*/    RTVJOBA    USER(&PUSR)
/*510 A*/    RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/*  Check if user is authorized to use this option              (CLD A) */

/*CLD A*/    IF         COND(&CLIENT *EQ &CITYLINE +
/*ICB M*/                *OR &CLIENT *EQ &ICB +
/*TPCaA*/                *OR &CLIENT *EQ &TPC +
/*GMM M*/                *OR &CLIENT *EQ &MENUMAKER +
/*KHL M*/                *OR &CLIENT *EQ &KOHL +
/*HAL A*/                *OR &CLIENT *EQ &HALSEY +
/*PFCaA*/                *OR &CLIENT *EQ &PRESTO +
/*GLP A*/                *OR &CLIENT *EQ &GLP +
/*MQS M*/                *OR &CLIENT *EQ &MQS +
/*SOF M*/                *OR &CLIENT *EQ &SOFO +
/*WIL A*/                *OR &CLIENT *EQ &WIL +
/*EI  A*/                *OR &CLIENT *EQ &Euroimport +
/*FFC A*/                *OR &CLIENT *EQ &FFC +
/*DRY A*/                *OR &CLIENT *EQ &Dairyland +
/*LKF A*/                *OR &CLIENT *EQ &LKF +
/*FGL A*/                *OR &CLIENT *EQ &FGL +
/*PAK M*/                *OR &CLIENT *EQ &PACKERS)  THEN(DO)
/*CLD A*/    CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)

/*PFCaA*/    IF         COND((&PRTN *EQ '*YES') *AND +
/*PFCaA*/                 (&CLIENT *EQ &PRESTO) *AND +
/*PFCaA*/                 (&PGMID *EQ '*ALL') *AND +
/*PFCaA*/                  (&PGMOPT *EQ '*ALL'))    +
/*PFCaA*/                   THEN(DO)
/*PFCaA*/               CHGVAR VAR(&PRTN) VALUE('*NO')
/*PFCaA*/    ENDDO

/*CLD A*/    IF         COND(&PRTN *EQ '*NO')  THEN(DO)
/*CLD A*/               SNDPGMMSG  MSG(&NOAUTHRZE)   +
/*CLD A*/               MSGTYPE(*INFO)
/*CLD A*/    RETURN
/*CLD A*/    ENDDO
/*CLD A*/    ENDDO
/*-------------------------------------------------------------------*/

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

             CALL       PGM(&PGM)

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
