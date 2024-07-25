/*********************************************************************/
/*                                                                   */
/*  DK100       Create Set Dock Door Matrix                          */
/*  19 February 2002                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: DK100CL                              */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WHSE        Warehouse                                           */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create Dock Door Matrix')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(15 5) RSTD(*NO) +
                          RANGE(1 998) MIN(1) PROMPT('Warehouse +
                          number')

