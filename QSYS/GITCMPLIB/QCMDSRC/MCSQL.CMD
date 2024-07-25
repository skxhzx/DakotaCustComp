/*-----------------------------------------------------------------*/
/*                                                                 */
/*  RUNSQLSTM Command to execute MCSQL001CL program                */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Command Processing Program: MCSQL001CL                         */
/*  Validity Checking Program:  None                               */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Revisions:                                                     */
/*  12/05/07  MLB  5.10                                            */
/*    - Renamed SQL001CL to MCSQL001CL to resolve parameter        */
/*      passing issues on clients' systems.                        */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  To compile:                                                    */
/*                                                                 */
/*     CRTCMD CMD(xxx/RUNSQLSTM) PGM(xxx/MCSQL001CL)               */
/*            SRCFILE(xxx/QCMDSRC)                                 */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Parameters                                                     */
/*     None                                                        */
/*                                                                 */
/*-----------------------------------------------------------------*/

             CMD        PROMPT('Run SQL Statement')

             PARM       KWD(STM) TYPE(*CHAR) LEN(1280) MIN(1) +
                          PROMPT('SQL statement')
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT *OUTFILE) +
                          EXPR(*YES) PROMPT('Output')
             PARM       KWD(OUTFILE) TYPE(Q1) PMTCTL(PC1) +
                          PROMPT('File to receive output')
             PARM       KWD(OUTMBR) TYPE(E1) PMTCTL(PC1) +
                          PROMPT('Output member options')

 PC1:        PMTCTL     CTL(OUTPUT) COND((*EQ *OUTFILE))

 Q1:         QUAL       TYPE(*NAME) LEN(10) DFT(OUTSQL) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) DFT(QTEMP) +
                          SPCVAL((*LIBL) (*CURLIB)) EXPR(*YES) +
                          PROMPT('Library')

 E1:         ELEM       TYPE(*NAME) LEN(10) DFT(*FIRST) +
                          SPCVAL((*FIRST)) EXPR(*YES) PROMPT('Member')
             ELEM       TYPE(*CHAR) LEN(8) RSTD(*YES) DFT(*REPLACE) +
                          VALUES(*REPLACE *ADD) EXPR(*YES) +
                          PROMPT('Replace or add records')
