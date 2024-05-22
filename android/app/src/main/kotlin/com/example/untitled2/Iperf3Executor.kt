
import java.io.File

object Iperf3Executor {
    fun runIperf3(command: List<String>): String {
        return try {
            val processBuilder = ProcessBuilder(command)
            val process = processBuilder.start()
            val reader = process.inputStream.bufferedReader()

            val output = StringBuilder()
            var line: String? = reader.readLine()
            while (line != null) {
                output.append(line).append("\n")
                line = reader.readLine()
            }

            process.waitFor()
            output.toString()
        } catch (e: Exception) {
            e.printStackTrace()
            "Error running iperf3: ${e.message}"
        }
    }
}
