package com.chronicle.journal.presentation.media

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Geocoder
import android.location.Location
import android.location.LocationManager
import androidx.core.content.ContextCompat
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.Locale
import javax.inject.Inject
import javax.inject.Singleton

data class JournalLocation(
    val name: String,
    val latitude: Double,
    val longitude: Double,
)

@Singleton
class LocationHelper
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
    ) {
        fun hasLocationPermission(): Boolean {
            val coarse =
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                ) == PackageManager.PERMISSION_GRANTED
            val fine =
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.ACCESS_FINE_LOCATION,
                ) == PackageManager.PERMISSION_GRANTED
            return coarse || fine
        }

        @SuppressLint("MissingPermission")
        suspend fun getCurrentLocation(): JournalLocation? =
            withContext(Dispatchers.IO) {
                if (!hasLocationPermission()) return@withContext null

                try {
                    val locationManager =
                        context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
                            ?: return@withContext null

                    val providers = locationManager.getProviders(true)
                    var bestLocation: Location? = null

                    for (provider in providers) {
                        val loc = locationManager.getLastKnownLocation(provider) ?: continue
                        if (bestLocation == null || loc.accuracy < bestLocation.accuracy) {
                            bestLocation = loc
                        }
                    }

                    val loc = bestLocation ?: return@withContext null
                    val lat = loc.latitude
                    val lon = loc.longitude

                    // Reverse geocode to city/locality name
                    var locationName = String.format(Locale.US, "%.2f, %.2f", lat, lon)
                    try {
                        val geocoder = Geocoder(context, Locale.getDefault())

                        @Suppress("DEPRECATION")
                        val addresses = geocoder.getFromLocation(lat, lon, 1)
                        if (!addresses.isNullOrEmpty()) {
                            val address = addresses[0]
                            val city = address.locality ?: address.subAdminArea ?: address.adminArea
                            val country = address.countryName
                            locationName =
                                if (city != null && country != null) {
                                    "$city, $country"
                                } else {
                                    city ?: country ?: locationName
                                }
                        }
                    } catch (e: Exception) {
                        // Ignore geocode failure and use coordinates
                    }

                    return@withContext JournalLocation(
                        name = locationName,
                        latitude = lat,
                        longitude = lon,
                    )
                } catch (e: Exception) {
                    return@withContext null
                }
            }
    }
