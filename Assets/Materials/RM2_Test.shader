Shader "RM2/Test"
{
    Properties
    {
        _Color ("Main Color (A=Opacity)", Color) = (1,1,1,1)
        _MainTex ("Base (A=Opacity)", 2D) = ""
    }

    Category
    {
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True"
        }

        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

        SubShader
        {
            Pass
            {
                SetTexture[_MainTex]
                {
                    Combine texture * constant ConstantColor[_Color]
                }
            }

            UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
        }


    }
}
