/*********************************************************************/
/*                                                                   */
/*  LVLCHKFILE   Check rec level id between programs and files.      */
/*  05 May 2003                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: LVLCHKFILE                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    05/05/03  DAS  4.17                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &PGMLIB      Program library                                     */
/*  &FILELIB     File library                                        */
/*  &OUTPUT      *DISPLAY, *PRINTER, *FILE                           */
/*  &OUTFILE     Output file for *FILE (Lib/File)                    */
/*  &OUTQ        Output queue for *PRINTER (Lib/Queue)               */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Pgm/File Record Level ID Check')

             PARM       KWD(PGMLIB) TYPE(*NAME) LEN(10) DFT(*NONE) +
                          SPCVAL((*NONE)) PROMPT('Program library')

             PARM       KWD(FILELIB) TYPE(*NAME) LEN(10) DFT(*NONE) +
                          SPCVAL((*NONE)) PROMPT('File library')

             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*DISPLAY) VALUES(*DISPLAY *PRINTER +
                          *OUTFILE) PROMPT('Output type')

             PARM       KWD(OUTFILE) TYPE(Q1) SNGVAL((*NONE)) +
                          PMTCTL(FILE) PROMPT('Output file')


 Q1:         QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) PROMPT('Library:')

 FILE:       PMTCTL     CTL(OUTPUT) COND((*EQ *OUTFILE))
