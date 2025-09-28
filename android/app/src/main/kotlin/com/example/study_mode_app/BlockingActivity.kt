package com.example.study_mode_app

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class BlockingActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make this activity full screen
        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )

        setContentView(createBlockingView())
    }

    private fun createBlockingView(): View {
        // Main Layout 
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#22223B")) // Dark blue background
            gravity = Gravity.CENTER
            setPadding(80, 80, 80, 80)
        }

        //  Emoji Icon 
        val emojiText = TextView(this).apply {
            text = "📚"
            textSize = 80f
            gravity = Gravity.CENTER
        }

        //  Title Text 
        val titleText = TextView(this).apply {
            text = "Study Mode Active"
            textSize = 28f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
        }

        //  Message Text 
        val messageText = TextView(this).apply {
            text = "This app is blocked.\nTime to focus!"
            textSize = 18f
            setTextColor(Color.parseColor("#F2E9E4")) // Softer off-white color
            gravity = Gravity.CENTER
            alpha = 0.9f
        }

        // Return Button with Programmatic Styling 
        val backButton = Button(this).apply {
            text = "Go Back"
            textSize = 16f
            setTextColor(Color.parseColor("#22223B"))
            isAllCaps = false
            typeface = Typeface.DEFAULT_BOLD

            // Create a rounded shape drawable programmatically
            val buttonShape = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                setColor(Color.parseColor("#C9ADA7"))
                cornerRadius = 100f
            }
            background = buttonShape

            //  Set padding directly on the button
            val horizontalPadding = (32 * resources.displayMetrics.density).toInt()
            val verticalPadding = (16 * resources.displayMetrics.density).toInt()
            setPadding(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding)

            setOnClickListener {
                val intent = Intent(this@BlockingActivity, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                startActivity(intent)
                finish()
            }
        }

        //  Layout Parameters for Spacing 
        val emojiParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            bottomMargin = 40
        }

        val titleParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            bottomMargin = 24
        }

        val messageParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            bottomMargin = 80
        }
        
        // The button's layout parameters no longer need the incorrect padding call
        val buttonParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )


        // Add all views to the main layout 
        layout.addView(emojiText, emojiParams)
        layout.addView(titleText, titleParams)
        layout.addView(messageText, messageParams)
        layout.addView(backButton, buttonParams)

        return layout
    }

    override fun onBackPressed() {
        // Prevent going back to the blocked app
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        startActivity(intent)
        finish()
    }
}