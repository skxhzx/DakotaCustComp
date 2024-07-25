/*********************************************************************/
/*                                                                   */
/*  BFCEMAIL    SEND EMAILS VIA GREEN SCREEN                         */
/*  08 MARCH   2019                                                  */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Calls BFCEMAILCL to send email                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &EMAILTO     Email Addresses separated by semi-colon             */
/*  &Subject     Email Subject                                       */
/*  &Body        Email Message                                       */
/*  &Path1       IFS Path for attachment 1                           */
/*  &Path2       IFS Path for attachment 2                           */
/*  &Path3       IFS Path for attachment 3                           */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Send iSeries Email')

             PARM       KWD(EMAILTO) TYPE(*CHAR) LEN(1000) +
                          PROMPT('Email To:')

             PARM       KWD(SUBJECT) TYPE(*CHAR) LEN(100) +
                          PROMPT('Email Subject')

             PARM       KWD(BODY) TYPE(*CHAR) LEN(5000) +
                          PROMPT('Email Message')

             PARM       KWD(PATH1) TYPE(*CHAR) LEN(100) PROMPT('IFS +
                          Path for attachment 1')

             PARM       KWD(PATH2) TYPE(*CHAR) LEN(100) PROMPT('IFS +
                          Path for attachment 2')

             PARM       KWD(PATH3) TYPE(*CHAR) LEN(100) PROMPT('IFS +
                          Path for attachment 3')
