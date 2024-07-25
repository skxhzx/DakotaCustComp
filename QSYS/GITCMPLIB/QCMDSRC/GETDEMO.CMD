/*********************************************************************/
/*                                                                   */
/*  GETDEMO     Get FILES and put into library BFCROUTEcc            */
/*  25 August 2007                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: CPYDEMO                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*    &CMD      *GETTABLE or *GETALL                                 */
/*    &CODE     Code to append to BFCDEMO                            */
/*    &LIBRARY  From library                                         */
/*    &FMDT     From date (yyyymmdd)                                 */
/*    &TODT     To date   (yyyymmdd)                                 */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Get files and put in BFCDeMO')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(9) +
                          PROMPT('*GETTABLE or *GETALL')


             PARM       KWD(CODE) TYPE(*CHAR) LEN(2) RTNVAL(*NO) +
                          RSTD(*NO) MIN(1) PROMPT('BFCDEMO library +
                          to use')

             PARM       KWD(LIBRARY) TYPE(*CHAR) LEN(10) +
                          PROMPT('From library')

             PARM       KWD(FMDTE) TYPE(*CHAR) LEN(8) +
                          PROMPT('From date yyyymmdd')
             PARM       KWD(TODTE) TYPE(*CHAR) LEN(8) +
                          PROMPT('To date yyyymmdd')

