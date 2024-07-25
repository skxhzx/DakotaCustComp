/*********************************************************************/
/*                                                                   */
/*  DOCK100CMD   SELECT POSTATUS RECORD TO ADD FROM POHDR            */
/*  02 October 2021                                                  */
/*  Todd Chopp                                                       */
/*                                                                   */
/*  Command Processing Program: DOCK100                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    10/02/21  TDC                                                  */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CMD         Command                                             */
/*  &WHSE        Warehouse                                           */
/*  &PO          Purchase order number                               */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Add PO to POSTATUS from POHDR')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) +
                           PROMPT('WAREHOUSE')

             PARM       KWD(PO) TYPE(*CHAR) LEN(10) RSTD(*NO) +
                          ALWUNPRT(*NO) PROMPT('PO NUMBER')
