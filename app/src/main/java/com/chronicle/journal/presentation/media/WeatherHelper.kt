package com.chronicle.journal.presentation.media

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.util.Locale
import javax.inject.Inject
import javax.inject.Singleton

data class JournalWeather(
    val summary: String,
    val temperatureCelsius: Float,
    val icon: String,
)

@Singleton
class WeatherHelper
    @Inject
    constructor() {
        suspend fun fetchWeather(
            latitude: Double,
            longitude: Double,
        ): JournalWeather? =
            withContext(Dispatchers.IO) {
                try {
                    val urlString =
                        String.format(
                            Locale.US,
                            "https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current_weather=true",
                            latitude,
                            longitude,
                        )
                    val url = URL(urlString)
                    val connection =
                        (url.openConnection() as HttpURLConnection).apply {
                            connectTimeout = 3000
                            readTimeout = 3000
                            requestMethod = "GET"
                        }

                    if (connection.responseCode != HttpURLConnection.HTTP_OK) {
                        return@withContext null
                    }

                    val reader = BufferedReader(InputStreamReader(connection.inputStream))
                    val response = reader.readText()
                    reader.close()

                    val json = JSONObject(response)
                    val current = json.getJSONObject("current_weather")
                    val temp = current.getDouble("temperature").toFloat()
                    val weatherCode = current.getInt("weathercode")

                    val (summary, icon) = decodeWeatherCode(weatherCode)

                    JournalWeather(
                        summary = summary,
                        temperatureCelsius = temp,
                        icon = icon,
                    )
                } catch (e: Exception) {
                    null // Graceful offline fallback
                }
            }

        private fun decodeWeatherCode(code: Int): Pair<String, String> =
            when (code) {
                0 -> "Clear skies" to "☀️"
                1, 2, 3 -> "Partly cloudy" to "⛅"
                45, 48 -> "Foggy" to "🌫️"
                51, 53, 55 -> "Drizzle" to "🌦️"
                61, 63, 65 -> "Rainy" to "🌧️"
                71, 73, 75 -> "Snow" to "❄️"
                77 -> "Snow grains" to "🌨️"
                80, 81, 82 -> "Rain showers" to "🌧️"
                85, 86 -> "Snow showers" to "🌨️"
                95, 96, 99 -> "Thunderstorm" to "⛈️"
                else -> "Mild" to "🌤️"
            }
    }
