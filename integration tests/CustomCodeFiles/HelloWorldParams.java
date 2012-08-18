/**
 * Copyright 2012 StackMob
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.stackmob.example;

import com.stackmob.core.customcode.CustomCodeMethod;
import com.stackmob.core.rest.ProcessedAPIRequest;
import com.stackmob.core.rest.ResponseToProcess;
import com.stackmob.sdkapi.SDKServiceProvider;

import java.net.HttpURLConnection;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HelloWorldParams implements CustomCodeMethod {

  @Override
  public String getMethodName() {
    return "hello_world_params";
  }

  @Override
  public List<String> getParams() {
    return Arrays.asList("param1","param2");
  }

  @Override
  public ResponseToProcess execute(ProcessedAPIRequest request, SDKServiceProvider serviceProvider) {
  	String param1 = request.getParams().get("param1");
  	String param2 = request.getParams().get("param2");
    Map<String, Object> map = new HashMap<String, Object>();
    if (request.getBody() != "") {
    	map.put("body", request.getBody());
    }
    map.put("param1", param1);
    map.put("param2", param2);
    return new ResponseToProcess(HttpURLConnection.HTTP_OK, map);
  }

}
