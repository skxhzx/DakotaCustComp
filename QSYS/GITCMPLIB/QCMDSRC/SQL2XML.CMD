  CMD   PROMPT('SQL to XML')

  PARM KWD(SQLSTMT)    TYPE(*CHAR) LEN(5000) MIN(1) +
                       EXPR(*YES) PROMPT('SQL statement')

  PARM KWD(TOXML)      TYPE(*CHAR) LEN(63) MIN(1) +
                       EXPR(*YES) PROMPT('To XML')

  PARM KWD(ROOT)       TYPE(*CHAR) LEN(32) MIN(1) +
                       EXPR(*YES) PROMPT('Document Root')

  PARM KWD(ENTITY)     TYPE(*CHAR) LEN(32) MIN(1) +
                       EXPR(*YES) PROMPT('Entity name')

  PARM KWD(XSL)        TYPE(*CHAR) LEN(63) DFT(*NONE) +
                       MIN(0) EXPR(*YES) PROMPT('XSL')

  PARM KWD(TITLE)      TYPE(*CHAR) LEN(120) DFT(*NONE) +
                       MIN(0) EXPR(*YES) PROMPT('Title')

  PARM KWD(TITLENAME)  TYPE(*CHAR) LEN(32) DFT(TITLE) +
                       MIN(0) EXPR(*YES) PROMPT('Title name') +
                       PMTCTL(HASTITLE)

  PARM KWD(COLHDRS)    TYPE(*CHAR) LEN(10) RSTD(*YES) +
                       DFT(*FLDNAM) VALUES(*FLDNAM *SQLLABEL *ANY) +
                       MIN(0) EXPR(*YES) PROMPT('Field name')

  PARM KWD(RPLSPCHAR)  TYPE(*CHAR) LEN(4) RSTD(*YES) DFT(*NO) +
                       VALUES(*YES *NO) MIN(0) EXPR(*YES) +
                       PROMPT('Replace special chars <>&"')

  PARM KWD(OUTEMPTYE)  TYPE(*CHAR) LEN(4) RSTD(*YES) DFT(*YES) +
                       VALUES(*YES *NO) MIN(0) EXPR(*YES) +
                       PROMPT('Output empty elements')

  PARM KWD(MODE)       TYPE(*CHAR) LEN(8) RSTD(*YES) +
                       DFT(*REPLACE) VALUES(*ADD *REPLACE) +
                       MIN(0) EXPR(*YES) PROMPT('Add/replace')

  PARM KWD(ENDROOT)    TYPE(*CHAR) LEN(4) RSTD(*YES) +
                       DFT(*YES) VALUES(*YES *NO) +
                       PROMPT('Close root')

  PARM KWD(NAMING)     TYPE(*CHAR) LEN(4) RSTD(*YES) +
                       DFT(*SYS) SPCVAL((*SYS ) (*SQL )) +
                       PMTCTL(*PMTRQS) PROMPT('Naming')

  PARM KWD(ACTION)     TYPE(*CHAR) LEN(9) RSTD(*YES) +
                       DFT(*CONTINUE) SPCVAL((*CONTINUE) (*ESCAPE)) +
                       PMTCTL(*PMTRQS) PROMPT('Action on error')

HASTITLE:   PMTCTL     CTL(TITLE) COND((*NE '*NONE'))
