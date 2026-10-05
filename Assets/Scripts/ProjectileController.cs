using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class ProjectileController : MonoBehaviour
{
    [SerializeField] private Transform barrel; 
    [SerializeField] private GameObject projectilePrefab; // Döp om till Prefab för tydlighet
    [SerializeField] private float speed;

    public void Update()
    {
        if (Mouse.current != null && Mouse.current.leftButton.wasPressedThisFrame)
        {
            GameObject spawned = Instantiate(projectilePrefab, barrel.position, barrel.rotation);
            
            Rigidbody rb = spawned.GetComponent<Rigidbody>();
            if (rb != null)
            {
                rb.linearVelocity = barrel.forward * speed; 
            }
            else
            {
                Rigidbody2D rb2d = spawned.GetComponent<Rigidbody2D>();
                if (rb2d != null) rb2d.linearVelocity = barrel.up * speed;
            }

            Destroy(spawned, 5f);
        }
    }
}