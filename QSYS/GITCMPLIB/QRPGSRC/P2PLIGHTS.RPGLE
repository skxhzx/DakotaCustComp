     h DftActgrp(*NO) ActGrp(*Caller)

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  P2PLIGHTS Pick to Pallet Lights ON/OFF
     *  25 October 2018
     *  Mike Rooker
     *
416  *    10/25/18  MR   7.20
     *      - Created
     *
730aA*    10/01/19  DAS  7.30a
     *      - Changed parameters to be similar to Fascor parms
     *
730bA*    10/08/19  DAS  7.30b
     *      - Fascor change API.
     *      - Added Side parameter to RPG and Java.
     *      - Changed position to be A, B ...
     *      - Changed status to be 0, 1.
     *
     *----------------------------------------------------------------
     * Notes
     *
     *
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     D cmd             s             10A
     D truckID         s             10A
     D palletPosition  s              1A
730bAD palletSide      s              1A
720bMD palletStatus    s              1A
     D ipWithPort      s             20A

     d returnString    s            512A
     D StringClass     c                   'java.lang.String'

     *----------------------------------------------------------------
     * Prototype for QCMDEXC
     *----------------------------------------------------------------
     D Exc_Cmd         PR                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     *----------------------------------------------------------------
     * Prototype for Java call function
     *----------------------------------------------------------------
     d PassString      PR              o   STATIC EXTPROC(*JAVA:
     d                                     'p2p.PalletLights':
     d                                     'turnOnOffLights')
     d                                     CLASS(*JAVA: StringClass)
     d String                          o   CLASS(*JAVA: StringClass)
730bMd                                      dim(5)
     d                                      Const

     *----------------------------------------------------------------
     * Prototype for Java String Object
     *----------------------------------------------------------------
     d crtString       PR              o   EXTPROC(*JAVA:
     d                                             StringClass :
     d                                             *CONSTRUCTOR)
     d RPGBytes                   65535A   Const Varying

     *----------------------------------------------------------------
     * Prototype for Java String's getBytes method
     *----------------------------------------------------------------
     d cvtToBytes      PR           512A   EXTPROC(*JAVA:
     d                                             'java.lang.String':
     d                                             'getBytes')
     d                                     Varying

     *----------------------------------------------------------------
     * Input/Output object
     *----------------------------------------------------------------
     d args            s               o   Class(*JAVA: StringClass)
730bMd                                     dim(5)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CallJavaPgm     pr
     d  id                                 const like(truckId)
     d  pos                                const like(palletPosition)
730bAd  side                               const like(palletSide)
     d  stat                               const like(palletStatus)

     d PrintToJobLog   PR            10I 0 ExtProc('Qp0zLprintf')
     d  szOutputStg                    *   Value OPTIONS(*STRING)
     d                                 *   Value OPTIONS(*STRING:*NOPASS)

     *----------------------------------------------------------------
     * Parameters
     *
     *   cmd              *OPEN   - Open and get out
     *                    *SET    - Set lights
     *                    *CLOSE  - Set on LR and leave
     *                    *TEST   - Does a test sequence to Id sent in
     *
     *   truckId          Pallet jack id
     *
730bM*   palletPosition   Pallet position (A, B, C ...) (Z = All Lights)
     *
730bA*   palletSide       Pallet side (L = Left, R=Right, B = Both)
     *                    Not used with palletPosition = Z
     *
730bM*   PalletStatus     Pallet status (0 = Off, 1 = On)
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    cmd
     c                   parm                    truckID
     c                   parm                    palletPosition
730bAc                   parm                    palletSide
     c                   parm                    palletStatus

      /free

       //Change directory to PIRJAVA

       Exc_Cmd('CD (''/PIRJAVA'')':200);

       select;

         when cmd = '*OPEN';
           CallJavaPgm('OPEN': '': '': '');

         when cmd = '*CLOSE';
           *inlr = *on;

         when cmd = '*TEST';
           CallJavaPgm(truckId: 'Z': '': '0');
           CallJavaPgm(truckId: 'A': 'R': '1');
           CallJavaPgm(truckId: 'A': 'L': '1');
           CallJavaPgm(truckId: 'B': 'R': '1');
           CallJavaPgm(truckId: 'B': 'L': '1');
           if palletPosition >= 'C';
             CallJavaPgm(truckId: 'C': 'R': '1');
             CallJavaPgm(truckId: 'C': 'L': '1');
           endif;
           CallJavaPgm(truckId: 'A': 'B': '0');
           CallJavaPgm(truckId: 'B': 'B': '0');
           if palletPosition >= 'C';
             CallJavaPgm(truckId: 'C': 'B': '0');
           endif;
           CallJavaPgm(truckId: 'Z': '': '1');
           CallJavaPgm(truckId: 'Z': '': '0');

         when cmd = '*SET';
           CallJavaPgm(truckId: palletPosition:
                       palletSide: palletStatus);

       endsl;

       return;

      /end-free


     *----------------------------------------------------------------
     *  CallJavaPgm     Call Java program to set lights
     *----------------------------------------------------------------

     p CallJavaPgm     b
     d CallJavaPgm     pi
     d  id                                 const like(truckId)
     d  pos                                const like(palletPosition)
     d  side                               const like(palletSide)
     d  stat                               const like(palletStatus)

      /free

        // Set IP:Port to used

        ipWithPort = '192.168.59.230:9988';

        // Set parameters for Java call

        args(1) = crtString(%trim(ipWithPort));
        args(2) = crtString(%trim(id));
        args(3) = crtString(pos);
        args(4) = crtString(side);
        args(5) = crtString(stat);

        //Java call

        returnString = cvtToBytes(PassString(args));

        if returnString > '';
          PrintToJobLog(returnString);
        endif;

      /end-free

     p                 e

