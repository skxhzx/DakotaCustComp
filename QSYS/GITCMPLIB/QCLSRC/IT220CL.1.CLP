/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT220CL   RF Inventory adjustments                               */
/*  07 April, 1997                                                   */
/*  Dave Sommerville                                                 */
/*  Roxanne Harrison                                                 */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*  11/09/09  MLB  5.30                                              */
/*    - Enh: Added client custom code support to pgm.                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Packer's Provision                      */
/*                                                                   */
/*    11/09/09  MLB  PAK                                             */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: European Imports                        */
/*    08/17/11  RH   EIa                                             */
/*      - Add user authorization check.                              */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Springfield Grocer                      */
/*                                                                   */
/*    06/29/09  RH   SGC                                             */
/*      - Add user authorization check.                              */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Inter County Bakers                     */
/*    04/04/12  MLB  ICB                                             */
/*      - Add user authorization check. Per Roxanne H. 04/04/12.     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: TPC                                     */
/*    01/09/19  GJA  TPC                                             */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Graves Menu Maker                       */
/*                                                                   */
/*    08/20/12  RH   GMM                                             */
/*      - Add to authorization check.                                */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Halsey Foodservice                      */
/*                                                                   */
/*    08/25/12  MLB  HAL                                             */
/*      - Add user authorization check per Tim S. skype 08/07/12.    */
/*      - Added Halsey to CLD mod.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Cash Wa Distributing                    */
/*                                                                   */
/*    04/24/13  MLB  CWD                                             */
/*      - Add user authorization check per Hemant skype 04/24/13.    */
/*      - Added Cashwa to CLD mod.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Greenleaf Produce                       */
/*    04/15/13  RH   GLP                                             */
/*      - Add user authorization check.                              */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Customized Distribution                 */
/*    01/31/13  RH   CDIa                                            */
/*      - Add user authorization check.                              */
/*    03/26/13  RH   CDIB                                            */
/*      - Fix, needed parm values.                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Will Foods                              */
/*    09/22/14  RH   WILa                                            */
/*      - Add to authorization check                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Kohl Wholesalew                         */
/*    08/11/14  LMC  KHL                                             */
/*      - Add user authorization check.                              */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Presto                                  */
/*                                                                   */
/*    06/07/18  GJA  PFCa                                            */
/*      - Add user authorization check per Dewey email  06/07/18.    */
/*      - Added Presto to CLD mod.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Sofo Foods                              */
/*    02/01/15  RH   SOF                                             */
/*      - Add user authorization check.                              */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Fischer Foods                           */
/*    09/28/15  RH   FFC                                             */
/*      - Add to authorization check                                 */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Marques Foods                           */
/*    06/25/18  RH   MQSa                                            */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Liebrs Kosher Foods                     */
/*    11/15/19  RH   LKFa                                            */
/*      - Add to authorization check.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Foods Galore                            */
/*                                                                   */
/*    10/26/21  MLB  FGL  zd#5730                                    */
/*      - Add to authorization check.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT220CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (530 A) */

             DCL        VAR(&PACKERS) TYPE(*CHAR) LEN(10) +
                          VALUE('PACKERS')                        /* (PAK A) */
             DCL        VAR(&EI) TYPE(*CHAR) LEN(10) +
                          VALUE('EI')                             /* (EIa A) */
             DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC       ')                     /* (SGC A) */
             DCL        VAR(&ICB) TYPE(*CHAR) LEN(10) +
                          VALUE('ICB       ')                     /* (ICB A) */
             DCL        VAR(&TPC) TYPE(*CHAR) LEN(10) +
                          VALUE('TPC       ')                     /* (TPCaA) */
/*GMM A*/    DCL        VAR(&MENUMAKER) TYPE(*CHAR) LEN(10) +
                          VALUE('MENUMAKER ')
             DCL        VAR(&KOHL) TYPE(*CHAR) LEN(10) +
                          VALUE('KOHL')                           /* (KHL A) */
             DCL        VAR(&HALSEY) TYPE(*CHAR) LEN(10) +
                          VALUE('HALSEY')                         /* (HAL A) */
             DCL        VAR(&PRESTO) TYPE(*CHAR) LEN(10) +
                          VALUE('PRESTOFOOD')                     /* (PFCaA) */
             DCL        VAR(&CASHWA) TYPE(*CHAR) LEN(10) +
                          VALUE('CASHWA')                         /* (CWD A) */
             DCL        VAR(&CDI) TYPE(*CHAR) LEN(10) +
                          VALUE('CDI')                            /* (CDIaA) */
             DCL        VAR(&GLP) TYPE(*CHAR) LEN(10) +
                          VALUE('GREENLEAF')                      /* (GLP A) */
/*MQS A*/    DCL        VAR(&MQS) TYPE(*CHAR) LEN(10) +
                          VALUE('MARQUES')                        /* (MQS A) */
             DCL        VAR(&SOFO) TYPE(*CHAR) LEN(10) +
                          VALUE('SOFOFOODS')                      /* (SOF A) */
/*FFC A*/    DCL        VAR(&FFC) TYPE(*CHAR) LEN(10) +
                          VALUE('FISCHER')
/*WIL A*/    DCL        VAR(&WIL) TYPE(*CHAR) LEN(10) +
                          VALUE('WILLFOODS')
/*LKF A*/    DCL        VAR(&LKF) TYPE(*CHAR) LEN(10) +
                          VALUE('LIEBERS  ')
/*FGL A*/    DCL        VAR(&FGL) TYPE(*CHAR) LEN(10) +
                          VALUE('FOODSGALOR')

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(IT220)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

  /* Informational message.                                       /* (PAK A) */

             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (PAK A) */

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (530 A) */
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)      /* (530 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)      /* (PAK A) */
             DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)      /* (PAK A) */
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)       /* (PAK A) */
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)      /* (PAK A) */
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)      /* (ICB A) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get Client ID */                                               /* (530 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (530 A) */
             RTVJOBA    USER(&USER)                               /* (ICB A) */


/*  Check if user is authorized to use this option                   (PAK A) */

             IF         COND(&CLIENT *EQ &PACKERS +
                          *OR &CLIENT *EQ &CDI +
                          *OR &CLIENT *EQ &SGC +
                          *OR &CLIENT *EQ &ICB +
                          *OR &CLIENT *EQ &TPC +
/*GMM M*/                 *OR &CLIENT *EQ &MENUMAKER +
                          *OR &CLIENT *EQ &HALSEY +
/*PFCAA*/                 *OR &CLIENT *EQ &PRESTO +
                          *OR &CLIENT *EQ &KOHL +
                          *OR &CLIENT *EQ &GLP +
                          *OR &CLIENT *EQ &CASHWA +
                          *OR &CLIENT *EQ &MQS +
                          *OR &CLIENT *EQ &SOFO +
/*FFC A*/                 *OR &CLIENT *EQ &FFC +
/*WIL A*/                 *OR &CLIENT *EQ &WIL +
/*LKF A*/                 *OR &CLIENT *EQ &LKF +
/*FGL A*/                 *OR &CLIENT *EQ &FGL +
                          *OR &CLIENT *EQ &EI        )  THEN(DO)  /* (PAK A) */
               CHGVAR     VAR(&PGMID) VALUE('IT220CL')            /* (ICB A) */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (ICB A) */
               CHGVAR     VAR(&PUSR)   VALUE(&USER)               /* (ICB A) */
               RTVJOBA    USER(&PUSR)                             /* (CDIbA) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR +
                            &PRTN)                                /* (PAK A) */
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (PAK A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (PAK A) */
                 RETURN                                           /* (PAK A) */
               ENDDO                                              /* (PAK A) */
             ENDDO                                                /* (PAK A) */

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
