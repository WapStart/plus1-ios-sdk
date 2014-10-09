/**
 * WPConst.h
 *
 * Copyright (c) 2013, Alexander Zaytsev <a.zaytsev@co.wapstart.ru>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   * Neither the name of the "Wapstart" nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef WapPlusDemo_WPConst_h
#define WapPlusDemo_WPConst_h

#define BANNER_WIDTH 320
#define BANNER_HEIGHT 50

#define BANNER_X_POS CGRectGetMidX(self.superview.frame) - BANNER_WIDTH / 2	// Center
//#define BANNER_X_POS self.superview.frame.size.width - BANNER_WIDTH		// Right
//#define BANNER_X_POS 0													// Left

#define MINIMIZED_BANNER_HEIGHT 20
#define DEFAULT_MINIMIZED_LABEL @"Открыть баннер"

#define STATUS_CODE_NO_BANNER 204
#define STATUS_CODE_OK 200

#define SERVER_HOST @"ro.plus1.wapstart.ru"
#define SDK_VERSION @"2.2.0"

#define SDK_PARAMETERS_HEADER @"X-Plus1-SDK-Parameters"
#define SDK_ACTION_HEADER @"X-Plus1-SDK-Action"

#define DEFAULT_REINIT_TIMEOUT 3600
#define DEFAULT_FACEBOOK_INFO_UPDATE_TIMEOUT 60
#define DEFAULT_TWITTER_INFO_UPDATE_TIMEOUT 60

#define WPSessionKey @"WPClientSessionId"

#endif
