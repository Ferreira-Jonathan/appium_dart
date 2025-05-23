import 'package:appium_driver/async_core.dart';
import 'package:appium_driver/src/common/request.dart';
import 'package:appium_driver/src/common/w3c/command.dart';
import 'package:appium_driver/src/common/webdriver_handler.dart';

import 'package:webdriver/src/common/request.dart'; // ignore: implementation_imports
import 'package:webdriver/src/common/session.dart'; // ignore: implementation_imports
import 'package:webdriver/src/common/capabilities.dart'; // ignore: implementation_imports
import 'package:webdriver/src/handler/w3c/utils.dart'; // ignore: implementation_imports

class W3cSessionHandler extends SessionHandler {
  @override
  WebDriverRequest buildCreateRequest({Map<String, dynamic>? desired}) {
    desired ??= Capabilities.empty;
    return WebDriverRequest.postRequest('session', {
      'capabilities': {
        'alwaysMatch': desired,
        'firstMatch': [{}]
      }
    });
  }

  @override
  SessionInfo parseCreateResponse(WebDriverResponse response) {
    // 'value' key in the WebDriver response as String
    final responseValue = parseW3cResponse(response);
    try {
      return SessionInfo(
          responseValue['sessionId'],
          WebDriverSpec.W3c,
          responseValue['capabilities']
      );
    } catch (_){
      // This case occurs when the server replied MJSONWP,
      // 200 ok plus error message in the body.
      throw SessionNotCreatedException(500, responseValue.toString());
    }
  }

  /// Requesting existing session info is not supported in W3c.
  @override
  WebDriverRequest buildInfoRequest(String id) =>
      WebDriverRequest.nullRequest(id);

  @override
  SessionInfo parseInfoResponse(WebDriverResponse response) =>
      SessionInfo(response.body!, WebDriverSpec.W3c, Capabilities.empty);

  @override
  WebDriverRequest buildGetCapabilitiesRequest() {
    return AppiumWebDriverRequest.sendRequest(W3CCommands.GET_CAPABILITIES);
  }

  @override
  Map<String, dynamic> parseGetCapabilitiesResponse(
      WebDriverResponse response) {
    return parseW3cResponse(response);
  }
}
