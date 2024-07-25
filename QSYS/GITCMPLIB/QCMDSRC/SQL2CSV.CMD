  CMD   PROMPT('SQL to Csv')

  PARM KWD(SQLSTMT)    TYPE(*CHAR) LEN(5000) MIN(1) +
                       EXPR(*YES) PROMPT('SQL statement')

  PARM KWD(TOCSV)      TYPE(*CHAR) LEN(63) MIN(1) +
                       EXPR(*YES) PROMPT('To Csv')

  PARM KWD(MODE)       TYPE(*CHAR) LEN(8) RSTD(*YES) +
                       DFT(*REPLACE) VALUES(*ADD *REPLACE)             +
                       MIN(0) EXPR(*YES) PROMPT('Add/replace')

  PARM KWD(COLHDRS)    TYPE(*CHAR) LEN(10) RSTD(*YES) +
                       DFT(*NONE) VALUES(*NONE *FLDNAM *SQLLABEL *ANY) +
                       MIN(0) EXPR(*YES) PROMPT('Column headers')

  PARM KWD(TITLE)      TYPE(*CHAR) LEN(120) DFT(*NONE) +
                       MIN(0) EXPR(*YES) PROMPT('Sheet title')

  PARM KWD(NAMING)     TYPE(*CHAR) LEN(4) RSTD(*YES) +
                       DFT(*SYS) SPCVAL((*SYS ) (*SQL )) +
                       PMTCTL(*PMTRQS) PROMPT('Naming')

