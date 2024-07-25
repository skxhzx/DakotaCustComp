/*********************************************************************/
/*                                                                   */
/*  STRAPTFTP  Start APTFTP server                                   */
/*  November 1, 2011                                                 */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Command Processing Program: STRAPTFTP                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    11/01/11  RTR  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &PUTJOBQ     Place on job queue (*YES)                           */
/*  &JOBD        Job description (Name/Lib)                          */
/*  &JOBQ        Job queue (Name/Lib)                                */
/*  &LIBL        Library list to use                                 */
/*                                                                   */
/*********************************************************************/
             CMD        PROMPT('Start APTFTP Server')

             PARM       KWD(PUTJOBQ) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) PROMPT('Place +
                          on job queue')

             PARM       KWD(JOBD) TYPE(Q1) SNGVAL((*USRPRF)) +
                          PMTCTL(JOBQCHK) PROMPT('Job Description')

             PARM       KWD(JOBQ) TYPE(Q2) PMTCTL(JOBQCHK) +
                          PROMPT('Job Queue')

             PARM       KWD(LIBL) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*JOBD) VALUES(*CURRENT *JOBD) +
                          PMTCTL(JOBQCHK) PROMPT('Library List')

 Q1:         QUAL       TYPE(*NAME) LEN(10) DFT(PIRJOBDAPT)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library:')

 Q2:         QUAL       TYPE(*NAME) LEN(10) DFT(*JOBD) SPCVAL((*JOBD))
             QUAL       TYPE(*NAME) LEN(10) SPCVAL((*LIBL)) +
                          PROMPT('Library:')

 JOBQCHK:    PMTCTL     CTL(PUTJOBQ) COND((*EQ *YES))

