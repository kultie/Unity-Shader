using System.Linq;
using System.Collections.Generic;
using UnityEngine;
public class PostProcessing : MonoBehaviour
{
    public Material material;


    private void Update()
    {
        Vector3 pos = Camera.main.ScreenToViewportPoint(Input.mousePosition); //0~1 mouse position
        //Vector3 pos = Camera.main.WorldToScreenPoint(Input.mousePosition);
        if (Input.GetMouseButtonDown(0)) {
            material.SetVector("_Position", pos);
            material.SetFloat("_StartWave", 1);
            material.SetFloat("_CurrentTime", Time.timeSinceLevelLoad);
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int passCount = material.passCount;
        if (passCount > 1)
        {
            RenderTexture tmp = RenderTexture.GetTemporary(source.width, source.height);
            RenderTexture tmp2 = RenderTexture.GetTemporary(source.width, source.height);
            for (int i = 0; i < passCount; i++)
            {
                if (i == 0)
                {
                    Graphics.Blit(source, tmp, material, i);
                }
                else if (i == passCount - 1)
                {
                    Graphics.Blit(tmp2, destination, material, i);
                }
                else
                {
                    Graphics.Blit(tmp, tmp2, material, i);
                }
            }
            //Graphics.Blit(source, tmp, material, 0);
            //Graphics.Blit(tmp, destination, material, 1);
            RenderTexture.ReleaseTemporary(tmp);
            RenderTexture.ReleaseTemporary(tmp2);
        }
        else {
            Graphics.Blit(source, destination, material);
        }
    }
}

