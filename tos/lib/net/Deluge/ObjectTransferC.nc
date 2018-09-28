/* Copyright (c) 2018, Eric B. Decker, Daniel J. Maltbie
 * Copyright (c) 2007 Johns Hopkins University.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/**
 * @author Chieh-Jan Mike Liang <cliang4@cs.jhu.edu>
 * @author Razvan Musaloiu-E. <razvanm@cs.jhu.edu>
 * @author Daniel J. Maltbie <dmaltbie@daloma.com>
 * @author Eric B. Decker <cire831@gmail.com>
 */

#include "DelugePageTransfer.h"
#include "StorageVolumes.h"

configuration ObjectTransferC
{
  provides interface ObjectTransfer;
  uses {
    interface BlockRead[uint8_t img_num];
    interface BlockWrite[uint8_t img_num];
    interface Leds;
  }
}

implementation
{
  components ObjectTransferP, DelugePageTransferC;
  components Crc16C;

  ObjectTransfer = ObjectTransferP;
  DelugePageTransferC.BlockRead = BlockRead;
  DelugePageTransferC.BlockWrite = BlockWrite;
  ObjectTransferP.DelugePageTransfer -> DelugePageTransferC.DelugePageTransfer;
  ObjectTransferP.Crc16 -> Crc16C;

  components new AMSenderC(AM_DELUGEADVMSG) as SendAdvMsg,
             new AMReceiverC(AM_DELUGEADVMSG) as ReceiveAdvMsg,
             new AMSenderC(AM_DELUGEREQMSG) as SendReqMsg,
             new AMReceiverC(AM_DELUGEREQMSG) as ReceiveReqMsg,
             new AMSenderC(AM_DELUGEDATAMSG) as SendDataMsg,
             new AMReceiverC(AM_DELUGEDATAMSG) as ReceiveDataMsg;

  ObjectTransferP.SendAdvMsg -> SendAdvMsg;
  ObjectTransferP.ReceiveAdvMsg -> ReceiveAdvMsg;
  DelugePageTransferC.SendReqMsg -> SendReqMsg;
  DelugePageTransferC.ReceiveReqMsg -> ReceiveReqMsg;
  DelugePageTransferC.SendDataMsg -> SendDataMsg;
  DelugePageTransferC.ReceiveDataMsg -> ReceiveDataMsg;
  DelugePageTransferC.AMPacket -> SendDataMsg;
  DelugePageTransferC.Leds = Leds;

  ObjectTransferP.BlockWrite = BlockWrite;

  components RandomC, new TimerMilliC() as Timer;
  ObjectTransferP.Random -> RandomC;
  ObjectTransferP.Timer -> Timer;

  // For collecting statistics
//  components StatsCollectorC;
//  ObjectTransferP.StatsCollector -> StatsCollectorC.StatsCollector;
}
