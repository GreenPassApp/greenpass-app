package eu.greenpassapp.greenpassrk

import android.net.Uri
import androidx.annotation.NonNull
import com.google.mlkit.vision.barcode.Barcode
import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "eu.greenpassapp.greenpass/mlkit_vision").setMethodCallHandler {
            call, result ->
            when (call.method) {
                "scanQrCodeInImage" -> {
                    try {
                        var image: InputImage = InputImage.fromFilePath(context, Uri.fromFile(File(call.argument<String>("filename")!!)))

                        var scanner : BarcodeScanner = BarcodeScanning.getClient(BarcodeScannerOptions.Builder()
                            .setBarcodeFormats(Barcode.FORMAT_QR_CODE)
                            .build())

                        scanner.process(image)
                            .addOnSuccessListener { barcodes ->
                                result.success(barcodes.map { r -> r.rawValue })
                            }
                            .addOnFailureListener {
                                result.error("DETECTION_ERROR", "There was an error detecting the QR code.", null)
                            }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("DETECTION_ERROR", "There was an error detecting the QR code.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
