const data = {
  'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTSzIzNzdmYjM4YjQ4MDUxMzAxNGY2ZDhhODU4NGMyNWFmLTE1NjUwNDI0MDkiLCJncmFudHMiOnsiaWRlbnRpdHkiOiJhZ2VudGJvYiIsInZvaWNlIjp7ImluY29taW5nIjp7ImFsbG93Ijp0cnVlfSwib3V0Z29pbmciOnsiYXBwbGljYXRpb25fc2lkIjoiQVA2Y2FmZWU3ZWY0YjgwNDM1ZjA0ZDEyYjk3NjRkMjMwMSJ9fX0sImlhdCI6MTU2NTA0MjQwOSwiZXhwIjoxNTY1MDQ2MDA5LCJpc3MiOiJTSzIzNzdmYjM4YjQ4MDUxMzAxNGY2ZDhhODU4NGMyNWFmIiwic3ViIjoiQUMxMGRlMzM5Nzc2NTM0N2I2MTRlMjI0Y2I3NzcwM2Y2YSJ9.3Ql_t9IAI5fTZI3FmvaibFmfclzXYYd7BXNyja1C4_k',
  'identity': 'Agent Bob'
  }

$(function () {

  if ( !data.token ||
    data.token === 'AGENT_BOBS_ACCESS_TOKEN') {
    log('You need to set Agent Bob\'s token before running this example')
    return;
  }

  var speakerDevices = document.getElementById('speaker-devices');
  var ringtoneDevices = document.getElementById('ringtone-devices');
  var outputVolumeBar = document.getElementById('output-volume');
  var inputVolumeBar = document.getElementById('input-volume');
  var volumeIndicators = document.getElementById('volume-indicators');

  var device;
  var connection;

  // Setup Twilio.Device
  device = new Twilio.Device(data.token);

  device.on('ready',function (device) {
    log('Twilio.Device Ready!');
    document.getElementById('call-controls').style.display = 'block';
    document.getElementById('button-answer').disabled = true;
  });

  device.on('error', function (error) {
    log('Twilio.Device Error: ' + error.message);
  });

  device.on('connect', function (conn) {
    log('Successfully established call!');
    document.getElementById('button-call').style.display = 'none';
    document.getElementById('button-hangup').style.display = 'inline';
    volumeIndicators.style.display = 'block';
    bindVolumeIndicators(conn);
  });

  device.on('disconnect', function (conn) {
    log('Call ended.');
    document.getElementById('button-call').style.display = 'inline';
    document.getElementById('button-hangup').style.display = 'none';
    volumeIndicators.style.display = 'none';
  });

  device.on('incoming', function (conn) {
    log('Got incoming call')
    const orderID = conn.customParameters.get('orderID');
    const name = conn.customParameters.get('name');

    log('Incoming connection from:' + name + ', orderID:' +  orderID);
    connection = conn;
    document.getElementById('button-answer').style.display = 'inline';
    document.getElementById('button-answer').disabled = false;
  });

  setClientNameUI(data.identity);

  device.audio.on('deviceChange', updateAllDevices.bind(device));

  // Show audio selection UI if it is supported by the browser.
  if (device.audio.isOutputSelectionSupported) {
    document.getElementById('output-selection').style.display = 'block';
  }


  document.getElementById('button-answer').onclick = function () {
    if (connection) {
      connection.accept();
    }

    document.getElementById('button-answer').disabled = true;
  }

  // Bind button to make call
  document.getElementById('button-call').onclick = function () {
    // get the phone number to connect the call to
    var params = {
      To: document.getElementById('phone-number').value
    };

    console.log('Calling ' + params.To + '...');
    if (device) {
      device.connect(params);
    }
  };

  // Bind button to hangup call
  document.getElementById('button-hangup').onclick = function () {
    log('Hanging up...');
    if (device) {
      device.disconnectAll();
    }
  };

  document.getElementById('get-devices').onclick = function() {
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(updateAllDevices.bind(device));
  }

  speakerDevices.addEventListener('change', function() {
    var selectedDevices = [].slice.call(speakerDevices.children)
      .filter(function(node) { return node.selected; })
      .map(function(node) { return node.getAttribute('data-id'); });

    device.audio.speakerDevices.set(selectedDevices);
  });

  ringtoneDevices.addEventListener('change', function() {
    var selectedDevices = [].slice.call(ringtoneDevices.children)
      .filter(function(node) { return node.selected; })
      .map(function(node) { return node.getAttribute('data-id'); });

    device.audio.ringtoneDevices.set(selectedDevices);
  });

  function bindVolumeIndicators(connection) {
    connection.on('volume', function(inputVolume, outputVolume) {
      var inputColor = 'red';
      if (inputVolume < .50) {
        inputColor = 'green';
      } else if (inputVolume < .75) {
        inputColor = 'yellow';
      }

      inputVolumeBar.style.width = Math.floor(inputVolume * 300) + 'px';
      inputVolumeBar.style.background = inputColor;

      var outputColor = 'red';
      if (outputVolume < .50) {
        outputColor = 'green';
      } else if (outputVolume < .75) {
        outputColor = 'yellow';
      }

      outputVolumeBar.style.width = Math.floor(outputVolume * 300) + 'px';
      outputVolumeBar.style.background = outputColor;
    });
  }

  function updateAllDevices() {
    updateDevices(speakerDevices, device.audio.speakerDevices.get());
    updateDevices(ringtoneDevices, device.audio.ringtoneDevices.get());


    // updateDevices(speakerDevices, );
    // updateDevices(ringtoneDevices, device);
  }

  // Update the available ringtone and speaker devices
  function updateDevices(selectEl, selectedDevices) {
    selectEl.innerHTML = '';

    device.audio.availableOutputDevices.forEach(function(device, id) {
      var isActive = (selectedDevices.size === 0 && id === 'default');
      selectedDevices.forEach(function(device) {
        if (device.deviceId === id) { isActive = true; }
      });

      var option = document.createElement('option');
      option.label = device.label;
      option.setAttribute('data-id', id);
      if (isActive) {
        option.setAttribute('selected', 'selected');
      }
      selectEl.appendChild(option);
    });
  }

  // Activity log
  function log(message) {
    var logDiv = document.getElementById('log');
    logDiv.innerHTML += '<p>&gt;&nbsp;' + message + '</p>';
    logDiv.scrollTop = logDiv.scrollHeight;
  }

  // Set the client name in the UI
  function setClientNameUI(clientName) {
    var div = document.getElementById('client-name');
    div.innerHTML = 'Your client name: <strong>' + clientName +
      '</strong>';
  }
});
