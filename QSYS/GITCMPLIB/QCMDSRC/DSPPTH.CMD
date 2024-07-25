/*===============================================================*/
/* To compile:                                                   */
/*                                                               */
/*           CRTCMD     CMD(XXXLIB/DSPPTH) PGM(XXXLIB/SRC630RG)  */
/*                       SRCMBR(SRC630CM)                        */
/*                                                               */
/*===============================================================*/
             CMD        PROMPT('DISPLAY ACCESS PATH')
             PARM       KWD(FILE) TYPE(NAME1) MIN(1) PROMPT('File +
                          Name:')
 NAME1:      QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*CHAR) LEN(10) DFT(*LIBL) SPCVAL((' ' +
                          *LIBL)) CHOICE('Name, *LIBL') +
                          PROMPT('Library Name:')
