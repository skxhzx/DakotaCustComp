     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  C#APTOUT   Dakota realtime interface - APT Output DS
     *  September 30, 2011
     *  Rod Roller
     *
     *  Revisions:
YHAaA*  02/22/2022  KDE  Add format 4 for Y-Hata Selection output
     *
     *----------------------------------------------------------------

     D #aptout         ds

     D  #aopfbldg                     6    Inz('001')
     D*                                    text('warehouse')
     D  #aopfseq                      6
     D*                                    text('record seq')
     D  #aopfbtch                     8
     D*                                    text('batch')
     D  #aopfdate                    10
     D*                                    text('datestamp')
     D  #aopftime                     6
     D*                                    text('timestamp')
     D  #aofill7                      7
     D*                                    text('filler')
     D  #aopfline                    15
     D*                                    text('order line')
     D  #aopfrte                     10
     D*                                    text('route')
     D  #aopfvi1                     10
     D*                                    text('slot qty')
     D  #aopfvi2                     10
     D*                                    text('batch pickup qty')
     D  #aopfvi3                     10
     D*                                    text('batch num aisles')
     D  #aopfvi4                     10
     D*                                    text('slot num slots')
     D  #aopfvi5                     10
     D*                                    text('batch num stops')
     D  #aopfvi6                     10
     D*                                    text('slot cw/slot')
     D  #aopfvi7                     10
     D*                                    text('batch num routes')
     D  #aopfvi8                     10
     D*                                    text('slot weight')
     D  #aopfvi9                     10
     D*                                    text('slot cubes')
     D  #aopfvi10                    10
     D*                                    text('batch pallets')
     D  #aopfill1                     1
     D*                                    text('filler')
     D  #aopfjob                      4
     D*                                    text('job code')
     D  #aopfill6                     6
     D*                                    text('rec type')
     D  #aopfrom                     10
     D*                                    text('from location')
     D  #aopto                       10
     D*                                    text('to location')
     D  #aopfill1a                    1
     D*                                    text('filler')
     D  #aopfrte2                     5
     D*                                    text('route')

     D #aptout2        ds

     D  #aodtbldg                     6    Inz('1')
     D*                                    text('building')
     D  #aodtseq                      6
     D*                                    text('record seq')
     D  #aodtpkr                      5
     D*                                    text('associate')
     D  #aodtsdate                   10
     D*                                    text('start date')
     D  #aodtstime                    6
     D*                                    text('start time')
     D  #aodtedate                   10
     D*                                    text('end date')
     D  #aodtetime                    6
     D*                                    text('end time')
     D  #aodtrun                      7
     D*                                    text('activity number')
     D  #aodtline                    15
     D*                                    text('line number')
     D  #aodtrte                     10
     D*                                    text('route number')

     D  #aodtvi1                     10
     D*                                    text('slot qty')
     D  #aodtvi2                     10
     D*                                    text('batch pickup qty')
     D  #aodtvi3                     10
     D*                                    text('batch num aisles')
     D  #aodtvi4                     10
     D*                                    text('slot num slots')
     D  #aodtvi5                     10
     D*                                    text('batch num stops')
     D  #aodtvi6                     10
     D*                                    text('slot cw/slot')
     D  #aodtvi7                     10
     D*                                    text('batch num routes')
     D  #aodtvi8                     10
     D*                                    text('slot weight')
     D  #aodtvi9                     10
     D*                                    text('slot cubes')
     D  #aodtvi10                    10
     D*                                    text('batch pallets')
     D  #aodtfill1                    1
     D*                                    text('filler 1')
     D  #aodtjob                      4
     D*                                    text('job code')
     D  #aodtfill6                    6
     D*                                    text('rec type')
     D  #aodtfrom                    10
     D*                                    text('from location')
     D  #aodtto                      10
     D*                                    text('to location')
     D  #aodtfill1a                   1
     D*                                    text('filler')
     D  #aodtfill4a                   4
     D*                                    text('filler')
     D  #aodtfill1b                   1
     D*                                    text('filler')
     D  #aodtarea                    10
     D*                                    text('area')

     D #aptout3        ds

     D  #aortbldg                     6a   Inz('1')
     D*                                    text('building')
     D  #aortpckr                     5s 0
     D*                                    text('picker nbr')
     D  #aortdelv                    10a
     D*                                    text('deliv date')
     D  #aortbatch                    7s 0
     D*                                    text('batch')
     D  #aortseq                      3s 0
     D*                                    text('seq')
     D  #aortresn                     1a
     D*                                    text('reason')
     D  #aortexcl                     1a
     D*                                    text('exclusion')
     D  #aortcinv                     7a
     D*                                    text('cred invc')
     D  #aortinvd                    10a
     D*                                    text('invc date')
     D  #aortrrte                     4a
     D*                                    text('ref route')
     D  #aortppe                     10a
     D*                                    text('pay perd')
     D  #aortcust                    10a
     D*                                    text('customer')
     D  #aortitem                     6a
     D*                                    text('item')
     D  #aortwhse                     2a
     D*                                    text('whse')
     D  #aortwhsa                     2a
     D*                                    text('whse area')
     D  #aortbcf                      1a
     D*                                    text('brkn case')
     D  #aortcqty                     5s 0
     D*                                    text('chrg qty')
     D  #aortoqty                     5s 0
     D*                                    text('orig qty')
     D  #aortcitm                     6a
     D*                                    text('corr item')
     D  #aortfil1                    78a
     D*                                    text('filler1')
     D  #aortadte                    10a
     D*                                    text('add date')

YHaA D #aptout4        ds

YHaA D  #aoDtaId                      3a
YHaA D*                                    text('DataFeedId')
YHaA D  #aoActTs                     23
YHaA D*                                    text('Activitiy TS')
YHaA D*  requested 2014-05-18 11:21:18.000
YHaA D  #aoBatchId                    8
YHaA D*                                    text('BatchId/Trans')
YHaA D  #aoLineSeq                    3  0
YHaA D*                                    text('Line Seq')
YHaA D  #aorte                       10
YHaA D*                                    text('Customer Route')
YHaA D  #aoTermId                     1a
YHaA D*                                    text('Terminal Id')
YHaA D  #aoZoneD                     30a
YHaA D*                                    text('Zone Desc')
YHaA D  #aoActMn                      6a
YHaA D*                                    text('Acct Main')
YHaA D  #aoActSb                      4a
YHaA D*                                    text('Acct Sub')
YHaA D  #aoFrmLoc                     8a
YHaA D*                                    text('From Loc')
YHaA D  #aoToLoc                      8a
YHaA D*                                    text('To Loc')
YHaA D  #aoEmpNum                     5  0
YHaA D*                                    text('Emp Num'))
YHaA D  #aokvi01                      3  0
YHaA D*                                    text('units')
YHaA D  #aokvi02                      7
YHaA D*                                    text('cube')
YHaA D  #aokvi03                      7
YHaA D*                                    text('weight')
YHaA D  #aokvi04                      1  0
YHaA D*                                    text('Loc/Trans Cnt')
YHaA D  #aokvi05                      2  0
YHaA D*                                    text('Stop cnt')
YHaA D  #aokvi06                      3  0
YHaA D*                                    text('Label cnt')
YHaA D  #aokvi07                      1  0
YHaA D*                                    text('PIR-0 FIX-1 or Pallet Cnt')
YHaA D  #aokvi08                      3  0
YHaA D*                                    text('Catchweight Cnt')
YHaA D  #aokvi09                      1  0
YHaA D*                                    text('not used')
YHaA D  #aokvi10                      1  0
YHaA D*                                    text('not used')
YHaA
