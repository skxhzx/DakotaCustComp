/* RESNDPO- Resend Exported P/O to Host.                           */
/*                                                                 */
/* The RESNDPO command allows one or more exported purchase orders */
/*   to be prepared to be resent to the Host system. This process  */
/*   creates the export files to be sent. The Re-Send option on    */
/*   P/O FTP menu will do the actual transmission.                 */
/*                                                                 */
/* The CPP is the RPG program RESNDPOCL                            */
/*                                                                 */
             CMD        PROMPT('Prepare P/O for ReSend to Host')
             PARM       KWD(WHSE) TYPE(*CHAR) LEN(3) RANGE(001 999) +
                          MIN(1) PROMPT('Warehouse number')
             PARM       KWD(PO) TYPE(*CHAR) LEN(9) +
                          MIN(1) PROMPT('Purchase order number')
             PARM       KWD(EXPDATE) TYPE(*CHAR) LEN(8) MIN(1) +
                          PROMPT('Exported date YYYYMMDD')
             PARM       KWD(EXPtime) TYPE(*CHAR) LEN(6) MIN(1) +
                          PROMPT('Exported time HHMMSS')
             PARM       KWD(mbr) TYPE(*CHAR) LEN(10) +
                          MIN(1) PROMPT('Export member name EXPmmdd')
