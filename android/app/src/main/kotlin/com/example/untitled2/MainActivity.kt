package com.example.untitled2

import android.os.Bundle
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterActivity() {

    private val CHANNEL = "iperf3"
    private val TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "copyIperf3Binary" -> {
                    val abi = getAbi()
                    Log.d(TAG, "Detected ABI: $abi")
                    val success = copyBinary("iperf3", abi)
                    if (success) {
                        result.success("Binary copied successfully")
                    } else {
                        result.error("COPY_FAILED", "Failed to copy iperf3 binary", null)
                    }
                }
                "executeIperf3TCP" -> {
                    val output = executeIperf3TCP()
                    result.success(output)
                }
                "executeIperf3UDP" -> {
                    val output = executeIperf3UDP()
                    result.success(output)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun executeIperf3TCP(): String {
        val processBuilder = ProcessBuilder("iperf3", "-c", "192.168.0.110", "-t", "5")
        processBuilder.redirectErrorStream(true)
        try {
            val process = processBuilder.start()
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = StringBuilder()
            var line: String? = reader.readLine()
            while (line != null) {
                output.append(line).append('\n')
                line = reader.readLine()
            }
            process.waitFor()
            return output.toString()
        } catch (e: Exception) {
            Log.e(TAG, "Error executing iperf3 TCP", e)
            return "Error executing iperf3 TCP: ${e.message}"
        }
    }

    private fun executeIperf3UDP(): String {
        val processBuilder = ProcessBuilder("iperf3", "-c", "192.168.0.110", "-t", "5", "-u")
        processBuilder.redirectErrorStream(true)
        try {
            val process = processBuilder.start()
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = StringBuilder()
            var line: String? = reader.readLine()
            while (line != null) {
                output.append(line).append('\n')
                line = reader.readLine()
            }
            process.waitFor()
            return output.toString()
        } catch (e: Exception) {
            Log.e(TAG, "Error executing iperf3 UDP", e)
            return "Error executing iperf3 UDP: ${e.message}"
        }
    }

    private fun getAbi(): String {
        return when (Build.SUPPORTED_ABIS[0]) {
            "armeabi-v7a" -> "armeabi-v7a"
            "arm64-v8a" -> "arm64-v8a"
            "x86" -> "x86"
            "x86_64" -> "x86_64"
            else -> throw IllegalArgumentException("Unsupported ABI: ${Build.SUPPORTED_ABIS[0]}")
        }
    }

    private fun copyBinary(filename: String, abi: String): Boolean {
        return try {
            val assetPath = "binaries/$abi/$filename"
            Log.d(TAG, "Copying binary from asset path: $assetPath")
            val inputStream: InputStream = assets.open(assetPath)
            val binaryDir = File(filesDir, "binaries/$abi")
            if (!binaryDir.exists()) {
                binaryDir.mkdirs()
                Log.d(TAG, "Created binary directory: ${binaryDir.absolutePath}")
            }
            val outFile = File(binaryDir, filename)
            val outputStream = FileOutputStream(outFile)

            val buffer = ByteArray(1024)
            var length: Int
            while (inputStream.read(buffer).also { length = it } > 0) {
                outputStream.write(buffer, 0, length)
            }

            inputStream.close()
            outputStream.close()

            // Make the file executable
            val executableSet = outFile.setExecutable(true)
            if (executableSet) {
                Log.d(TAG, "Made file executable: ${outFile.absolutePath}")
            } else {
                Log.e(TAG, "Failed to make file executable: ${outFile.absolutePath}")
            }
            Log.d(TAG, "Binary copied to: ${outFile.absolutePath}")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error copying binary", e)
            false
        }
    }
}
