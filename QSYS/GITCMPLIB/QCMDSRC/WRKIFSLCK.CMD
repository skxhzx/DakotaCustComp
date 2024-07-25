/*********************************************************************/
/*                                                                   */
/*  WRKIFSLCK    Work with IFS Object Locks                          */
/*  16 August 2021                                                   */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Command Processing Program: WRKIFSLCK                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    08/16/21  MLB  7.50                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Parameters                                                       */
/*  &PATH        IFS Folder path                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
             CMD
             PARM       KWD(PATH) TYPE(*CHAR) LEN(500) PROMPT('Work +
                          w/IFS Obj Locks Path')

