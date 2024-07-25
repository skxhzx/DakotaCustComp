
     *----------------------------------------------------------------
     * Begin C#STDVAR - Standard variable and constants
     *                  12/20/02  DAS  4.16  Created
     *                  04/03/13  DAS  6.50a Added true/false
     *                  12/21/13  DAS  6.50b Added RecordLocked
710a *                  06/10/17  DAS  7.10a Added cr/lf fields
720a *                  10/19/18  DAS  7.20a Added ex fields for EX programs
720a *                  08/14/19  DAS  7.30a Added um fields for UM programs
     *----------------------------------------------------------------

650b D recordLocked    c                   const(01218)

650a D false           c                   const(*off)
650a D true            c                   const(*on)

720aAD exRtnCode       s             10
720aAD exRtnMsg        s             60
720aAD exWhse          s              3s 0

730aAD umRtnCode       s             10
730aAD umRtnMsg        s             60
730aAD umWhse          s              3s 0
730aAD umFlexPickFlag  s              5

     D activerec       c                   'A'
     D deletedrec      c                   'D'
     D inactiverec     c                   'I'

     D null            c                   x'00'
     D quote           c                   Const('''')
     D sq              c                   Const('''')
     D dq              c                   Const('"')

     D F1              C                   const(X'31')
     D F2              C                   const(X'32')
     D F3              C                   const(X'33')
     D F4              C                   const(X'34')
     D F5              C                   const(X'35')
     D F6              C                   const(X'36')
     D F7              C                   const(X'37')
     D F8              C                   const(X'38')
     D F9              C                   const(X'39')
     D F10             C                   const(X'3A')
     D F11             C                   const(X'3B')
     D F12             C                   const(X'3C')
     D F13             C                   const(X'B1')
     D F14             C                   const(X'B2')
     D F15             C                   const(X'B3')
     D F16             C                   const(X'B4')
     D F17             C                   const(X'B5')
     D F18             C                   const(X'B6')
     D F19             C                   const(X'B7')
     D F20             C                   const(X'B8')
     D F21             C                   const(X'B9')
     D F22             C                   const(X'BA')
     D F23             C                   const(X'BB')
     D F24             C                   const(X'BC')

     D Enter           C                   const(X'F1')
     D PageUp          C                   const(X'F4')
     D PageDown        C                   const(X'F5')

     D changed         s               n
     D error           s               n
     D found           s               n
     D forever         s               n   inz(*ON)
     D leavepgm        s               n
     D lock            s               n
     D lock1           s               n
     D lock2           s               n
     D lock3           s               n
     D lock4           s               n
     D lock5           s               n
     D filebeg         s               n
     D fileend         s               n
     D warn            s               n

     D i               s              7  0
     D j               s              7  0
     D x               s              7  0
     D y               s              7  0
     D loopmax         s              7  0

710aAD cr              c                   Const(x'0D')
710aAD crlf            c                   Const(x'0D25')
710aAD eof             c                   Const(x'00')
710aAD lf              c                   Const(x'25')
710aAD lfcrlf          c                   Const(x'250D25')
     *** End C#STDVAR ***
