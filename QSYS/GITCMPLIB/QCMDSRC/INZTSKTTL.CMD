/*********************************************************************/
/*                                                                   */
/*  INZTSKTTL   Initialize task totals.                              */
/*  28 February 1996                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: TD911CL                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CAT         Category                                            */
/*  &SUBCAT      Sub-category                                        */
/*  &TASK        Task                                                */
/*  &WHSE        Warehouse                                           */
/*  &WHDP        Warehouse department                                */
/*  &STYP        Section                                             */
/*  &ETIME       End time                                            */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Initialize Task Totals')

             PARM       KWD(CAT) TYPE(*NAME) LEN(6) SPCVAL((*ALL)) +
                          MIN(1) PROMPT('Category')

             PARM       KWD(SUBCAT) TYPE(*NAME) LEN(6) +
                          SPCVAL((*ALL)) MIN(1) PROMPT('Sub-Category')

             PARM       KWD(TASK) TYPE(*NAME) LEN(6) SPCVAL((*ALL)) +
                          MIN(1) PROMPT('Task')

             PARM       KWD(WHSE) TYPE(*NAME) LEN(4) SPCVAL((*ALL)) +
                          MIN(1) PROMPT('Warehouse')

             PARM       KWD(WHDP) TYPE(*NAME) LEN(5) SPCVAL((*ALL)) +
                          MIN(1) PROMPT('Warehouse department')

             PARM       KWD(STYP) TYPE(*NAME) LEN(4) RSTD(*YES) +
                          VALUES(F P) SPCVAL((*ALL)) MIN(1) +
                          PROMPT('Section')

             PARM       KWD(ETIME) TYPE(*DEC) LEN(4) RANGE(0 2359) +
                          MIN(1) PROMPT('Ending time')

