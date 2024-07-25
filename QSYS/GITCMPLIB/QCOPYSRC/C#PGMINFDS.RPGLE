
     *----------------------------------------------------------------
     * Begin C#PGMINFDS - Program information data structure
     *  12/20/02  DAS  4.16  Created
600aA*  07/12/08  DAS  6.00a
     *    - Added #curruser, #prog, #jobn
640 A*  03/02/11  MLB  6.40
     *    - Added #parms
710a *  06/07/17  RTR  7.10a
     *    - Added #pgmlib
     *----------------------------------------------------------------
     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
600aAD  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
640 AD  #parms                37     39
710aAD  #pgmlib               81     90
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
600aAD  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
600aAD  #curruser            358    367

     *** End C#PGMINFDS ***
