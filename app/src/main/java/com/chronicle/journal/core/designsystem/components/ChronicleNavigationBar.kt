package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.border
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.CollectionsBookmark
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.presentation.navigation.Screen

data class NavItem(
    val route: String,
    val label: String,
    val icon: ImageVector,
)

val navigationItems =
    listOf(
        NavItem(Screen.Home.route, "Home", Icons.Default.Home),
        NavItem(Screen.Journal.route, "Journal", Icons.Default.CollectionsBookmark),
        NavItem(Screen.Calendar.route, "Calendar", Icons.Default.CalendarMonth),
        NavItem(Screen.Insights.route, "Insights", Icons.Default.AutoAwesome),
        NavItem(Screen.Settings.route, "Settings", Icons.Default.Settings),
    )

@Composable
fun ChronicleNavigationBar(
    currentRoute: String?,
    onNavigateToRoute: (String) -> Unit,
) {
    val colors = LocalChronicleColors.current

    NavigationBar(
        containerColor = colors.paperBackground,
        tonalElevation = 4.dp,
        modifier =
            Modifier
                .shadow(6.dp, RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp))
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp)),
    ) {
        navigationItems.forEach { item ->
            val isSelected = currentRoute == item.route
            NavigationBarItem(
                selected = isSelected,
                onClick = {
                    if (currentRoute != item.route) {
                        onNavigateToRoute(item.route)
                    }
                },
                icon = {
                    Icon(
                        imageVector = item.icon,
                        contentDescription = item.label,
                    )
                },
                label = {
                    Text(
                        text = item.label,
                        fontFamily = FontFamily.Monospace,
                        fontSize = 10.sp,
                    )
                },
                colors =
                    NavigationBarItemDefaults.colors(
                        selectedIconColor = colors.paperCard,
                        selectedTextColor = colors.inkPrimary,
                        indicatorColor = colors.inkPrimary,
                        unselectedIconColor = colors.inkMuted,
                        unselectedTextColor = colors.inkMuted,
                    ),
            )
        }
    }
}
