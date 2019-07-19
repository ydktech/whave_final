package jp.espresso3389.flutter_rtmp_publisher

import android.Manifest
import android.util.LongSparseArray
import com.takusemba.rtmppublisher.CameraMode
import com.takusemba.rtmppublisher.RtmpPublisher
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.view.TextureRegistry

class FlutterRtmpPublisherPlugin(
  registrar: Registrar): MethodCallHandler {

  private var registrar: Registrar = registrar
  private var textures: LongSparseArray<RtmpPublisherWrapper> = LongSparseArray()

  private val BITRATE_MAGIC_DIVIDER = 13 // 720p@30fps => 2MB
  private val AUDIO_BITRATE = 128 * 1024

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "jp.espresso3389.flutter_rtmp_publisher")
      channel.setMethodCallHandler(FlutterRtmpPublisherPlugin(registrar))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when {
      call.method == "alloc" -> {
        val tex = registrar.textures().createSurfaceTexture()
        val textureId = tex.id()
        val rtmpPub = RtmpPublisherWrapper(textureId, registrar, tex)
        textures.put(textureId, rtmpPub)
        result.success(textureId)
      }
      call.method == "release" -> {
        val tex = call.argument<Number>("tex")!!.toLong()
        val rtmpPub = textures[tex]
        rtmpPub.pub.release()
        textures.delete(tex)
        result.success(true)
      }
      call.method == "initCaptureConfig" -> {
        PermissionRequester.requestPermissions(registrar, arrayOf(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)) {
          grantAll ->
          if (!grantAll) {
            result.success(false)
          } else {
            val tex = call.argument<Number>("tex")!!.toLong()
            val rtmpPub = textures[tex]
            val width = call.argument<Number>("width")!!.toInt()
            val height = call.argument<Number>("height")!!.toInt()
            val fps = call.argument<Number>("fps")!!.toInt()
            val camera = if (call.argument<String>("camera") == "back") CameraMode.BACK else CameraMode.FRONT
            val audioBitRate = AUDIO_BITRATE
            val videoBitRate = width * height * fps / BITRATE_MAGIC_DIVIDER
            rtmpPub.pub.setCaptureConfig(width, height, fps, camera, audioBitRate, videoBitRate)
            result.success(true)
          }
        }
      }
      call.method == "pause" -> {
        val tex = call.argument<Number>("tex")!!.toLong()
        val rtmpPub = textures[tex]
        rtmpPub.pub.pause()
        result.success(true)
      }
      call.method == "resume" -> {
        val tex = call.argument<Number>("tex")!!.toLong()
        val rtmpPub = textures[tex]
        rtmpPub.pub.resume()
        result.success(true)
      }
      call.method == "startPreview" -> {
        val tex = call.argument<Number>("tex")!!.toLong()
        val rtmpPub = textures[tex]
        rtmpPub.pub.onResume()
        result.success(true)
      }
      call.method == "stopPreview" -> {
        val tex = call.argument<Number>("tex")!!.toLong()
        val rtmpPub = textures[tex]
        rtmpPub.pub.onPause()
        result.success(true)
      }
      call.method == "connect" -> {
        val tex = call.argument<Number>("tex")!!.toLong()
        var rtmpUrl = call.argument<String>("url")
        val name = call.argument<String>("name")

        if (!rtmpUrl!!.endsWith('/')) {
          rtmpUrl += "/"
        }
        // RTMP Publisher accepts one URL that contains stream name
        rtmpUrl += name

        val rtmpPub = textures[tex]
        rtmpPub.pub.startPublishing(rtmpUrl!!)
        result.success(true)
      }
      call.method == "disconnect" -> {
        val tex = call.argument<Number>("tex")!!.toLong()
        val rtmpPub = textures[tex]
        rtmpPub.pub.stopPublishing()
        result.success(true)
      }
      call.method == "initFramework" -> {
        // nothing for framework initialization
        result.success(true)
      }
      else -> result.notImplemented()
    }
  }

  class RtmpPublisherWrapper(textureId: Long, registrar: Registrar, flutterTexture: TextureRegistry.SurfaceTextureEntry): RtmpPublisher.RtmpPublisherListener {
    private val eventChannel: EventChannel = EventChannel(registrar.messenger(), "jp.espresso3389.flutter_rtmp_publisher.instance-$textureId")
    private val glSurfaceView: FlutterGLSurfaceView = FlutterGLSurfaceView(registrar, flutterTexture.surfaceTexture())
    val pub: RtmpPublisher = RtmpPublisher(registrar, glSurfaceView, CameraMode.BACK, this, object: RtmpPublisher.CameraCallback() {
      override fun onCameraSizeDetermined(width: Int, height: Int) { glSurfaceView.setSurfaceTextureSize(width, height) }
    })
    private var eventSink: EventChannel.EventSink? = null

    init {
      eventChannel.setStreamHandler(object: EventChannel.StreamHandler {
        override fun onListen(obj: Any?, eventSink: EventChannel.EventSink?) {
          this@RtmpPublisherWrapper.eventSink = eventSink
        }
        override fun onCancel(obj: Any?) {
          this@RtmpPublisherWrapper.eventSink = null
        }
      })
    }

    override fun onConnected() {
      eventSink!!.success("connected")
    }

    override fun onFailedToConnect() {
      eventSink!!.success("failedToConnect")
    }

    override fun onPaused() {
      eventSink!!.success("paused")
    }

    override fun onResumed() {
      eventSink!!.success("resumed")
    }

    override fun onDisconnected() {
      eventSink!!.success("disconnected")
    }
  }
}

